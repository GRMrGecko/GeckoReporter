//
//  MGMReporter.m
//  GeckoReporter
//
//  Created by Mr. Gecko on 12/27/09.
//  Copyright 2010 by Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMReporter.h"
#import "MGMReportWindow.h"
#import "MGMSender.h"
#import "MGMSystemInfo.h"
#import "MGMLog.h"

NSString * const MGMReportsPath = @"~/Library/Logs/CrashReporter";
NSString * const MGMGRDoneNotification = @"MGMGRDoneNotification";
NSString * const MGMGRUserEmail = @"MGMGRUserEmail";
NSString * const MGMGRUserName = @"MGMGRUserName";
NSString * const MGMGRLastCrashDate = @"MGMGRLastCrashDate";
NSString * const MGMGRSendAll = @"MGMGRSendAll";
NSString * const MGMGRIgnoreAll = @"MGMGRIgnoreAll";

@implementation MGMReporter
+ (id)sharedReporter {
    return [[self alloc] init];
}
- (id)init {
	if (self = [super init]) {
		foundReport = NO;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(done:) name:MGMGRDoneNotification object:nil];
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		if ([userDefaults objectForKey:MGMGRIgnoreAll]==nil || ![[userDefaults objectForKey:MGMGRIgnoreAll] boolValue]) {
			NSFileManager *manager = [NSFileManager defaultManager];
			NSString *applicationName = [[[MGMSystemInfo new] autorelease] applicationEXECName];
			if (lastDate!=nil) {
				[lastDate release];
				lastDate = nil;
			}
			lastDate = [[userDefaults objectForKey:MGMGRLastCrashDate] retain];
			NSDirectoryEnumerator *crashFiles = [manager enumeratorAtPath:[MGMReportsPath stringByExpandingTildeInPath]];
			NSString *crashFile = nil;
			NSString *lastCrashFile = nil;
			while (crashFile = [crashFiles nextObject]) {
				if ([crashFile hasPrefix:applicationName]) {
					NSString *file = [[MGMReportsPath stringByAppendingPathComponent:crashFile] stringByResolvingSymlinksInPath];
					BOOL readable = [manager isReadableFileAtPath:file];
					NSDictionary *attributes = [crashFiles fileAttributes];
					NSDate *creationDate = [attributes objectForKey:NSFileCreationDate];
					if (readable && (lastDate==nil || (creationDate==[lastDate laterDate:creationDate]))) {
						if (lastDate!=nil) {
							[lastDate release];
							lastDate = nil;
						}
						lastDate = [creationDate retain];
						lastCrashFile = file;
						foundReport = YES;
					}
				}
			}
			if (foundReport) {
				MGMLog(@"Latest Crash Report %@, %@", lastDate, lastCrashFile);
				if ([userDefaults objectForKey:MGMGRSendAll]!=nil && [[userDefaults objectForKey:MGMGRSendAll] boolValue]) {
					if (mailSender==nil) {
						mailSender = [MGMSender new];
						[mailSender sendReport:lastCrashFile reportDate:lastDate userReport:@"User set to send all." delegate:self];
					}
				} else {
					[MGMReportWindow sharedWindowWithReport:lastCrashFile reportDate:lastDate];
				}
			} else {
				[[NSNotificationCenter defaultCenter] postNotificationName:MGMGRDoneNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], MGMSaveLastDate, nil]];
			}
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:MGMGRDoneNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], MGMSaveLastDate, nil]];
		}
	}
	return self;
}

- (void)dealloc {
#if MGMGRReleaseDebug
	MGMLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	if (lastDate!=nil)
		[lastDate release];
	if (mailSender!=nil)
		[mailSender release];
	[super dealloc];
}
- (void)done:(NSNotification *)note {
	if ([[note userInfo] objectForKey:MGMSaveLastDate]!=nil && [[[note userInfo] objectForKey:MGMSaveLastDate] boolValue]) {
		[[NSUserDefaults standardUserDefaults] setObject:lastDate forKey:MGMGRLastCrashDate];
	}
	[self release];
	self = nil;
}

- (void)sendError:(NSError *)error {
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMGRDoneNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], MGMSaveLastDate, nil]];
}

- (void)sendFinished:(NSString *)received {
	MGMLog(@"%@", received);
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMGRDoneNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], MGMSaveLastDate, nil]];
}
@end