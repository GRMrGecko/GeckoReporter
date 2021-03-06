//
//  MGMReportWindow.m
//  GeckoReporter
//
//  Created by Mr. Gecko on 12/27/09.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//
//  Permission to use, copy, modify, and/or distribute this software for any purpose
//  with or without fee is hereby granted, provided that the above copyright notice
//  and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
//  REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT,
//  OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
//  DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
//  ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

#import "MGMReportWindow.h"
#import "MGMReporter.h"
#import "MGMSender.h"
#import "MGMSystemInfo.h"
#import "MGMLocalized.h"
#import "MGMLog.h"

NSString * const MGMSaveLastDate = @"MGMSaveLastDate";

@implementation MGMReportWindow
+ (id)sharedWindowWithReport:(NSString *)theReportFile reportDate:(NSDate *)theReportDate {
	return [[self alloc] initWithReport:theReportFile reportDate:theReportDate];
}
- (id)initWithReport:(NSString *)theReportFile reportDate:(NSDate *)theReportDate {
	if ((self = [super init])) {
		if (![NSBundle loadNibNamed:@"MGMReportWindow" owner:self]) {
			[self release];
			self = nil;
		} else {
			reportFile = [theReportFile retain];
			reportDate = [theReportDate retain];
			NSUserDefaults *userDefautls = [NSUserDefaults standardUserDefaults];
			MGMSystemInfo *sysInfo = [MGMSystemInfo info];
			NSString *applicationName = [sysInfo applicationName];
			
			appMainMenu = [[[NSApplication sharedApplication] mainMenu] retain];
			[[NSApplication sharedApplication] setMainMenu:mainMenu];
			if ([sysInfo isUIElement])
				[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
			else
				[[NSApplication sharedApplication] requestUserAttention:NSInformationalRequest];
			NSBeep();
			
			if (applicationName==nil)
				applicationName = [sysInfo applicationEXECName];
			[hideMenu setTitle:[NSString stringWithFormat:MGMLocalized(@"Hide %@", nil), applicationName]];
			[quitMenu setTitle:[NSString stringWithFormat:MGMLocalized(@"Quit %@", nil), applicationName]];
			
			[titleField setStringValue:[NSString stringWithFormat:MGMLocalized(@"%@ crashed the last time you ran it. Would you like to send me a crash report so I can look into it?", nil), applicationName]];
			[dateField setStringValue:[reportDate descriptionWithCalendarFormat:MGMLocalized(@"%a, %m/%d/%Y %I:%M:%S %p", nil) timeZone:nil locale:nil]];
			[mainWindow setTitle:[NSString stringWithFormat:MGMLocalized(@"%@ Crashed", nil), applicationName]];
			
			if ([userDefautls objectForKey:MGMGRUserEmail])
				[userEmailField setStringValue:[userDefautls objectForKey:MGMGRUserEmail]];
			
			[mainWindow makeKeyAndOrderFront:self];
		}
		
	}
	return self;
}
- (void)dealloc {
#if MGMGRReleaseDebug
	MGMLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[reportFile release];
	[reportDate release];
	[mailSender release];
	[mainWindow release];
	[super dealloc];
}

- (void)setButtonsEnabled:(BOOL)flag {
	[sendButton setEnabled:flag];
	[sendAllButton setEnabled:flag];
	[ignoreButton setEnabled:flag];
	[ignoreAllButton setEnabled:flag];
}

- (void)close {
	[[NSApplication sharedApplication] setMainMenu:appMainMenu];
	[appMainMenu release];
	[mainWindow orderOut:self];
	[self release];
	self = nil;
}

- (IBAction)sendReport:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[userEmailField stringValue] forKey:MGMGRUserEmail];
	if (mailSender==nil) {
		mailSender = [MGMSender new];
		[mailSender sendReport:reportFile reportDate:reportDate userReport:[[userReportView textStorage] string] delegate:self];
	}
	[sendButton setTitle:MGMLocalized(@"Sending...", nil)];
	[self setButtonsEnabled:NO];
}
- (IBAction)sendAllReports:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[userEmailField stringValue] forKey:MGMGRUserEmail];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:MGMGRSendAll];
	if (mailSender==nil) {
		mailSender = [MGMSender new];
		[mailSender sendReport:reportFile reportDate:reportDate userReport:[[userReportView textStorage] string] delegate:self];
	}
	[sendAllButton setTitle:MGMLocalized(@"Sending...", nil)];
	[self setButtonsEnabled:NO];
}
- (IBAction)ignoreReport:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMGRDoneNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], MGMSaveLastDate, nil]];
	[self close];
}
- (IBAction)ignoreAllReports:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:MGMGRIgnoreAll];
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMGRDoneNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], MGMSaveLastDate, nil]];
	[self close];
}

- (void)sendError:(NSError *)error {
	NSAlert *theAlert = [[NSAlert new] autorelease];
	[theAlert addButtonWithTitle:MGMLocalized(@"Ok", nil)];
	[theAlert setMessageText:MGMLocalized(@"Error could not send crash report.", nil)];
	[theAlert setInformativeText:[error localizedDescription]];
	[theAlert setAlertStyle:2];
	[theAlert runModal];
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMGRDoneNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], MGMSaveLastDate, nil]];
	[self close];
}

- (void)sendFinished:(NSString *)received {
	MGMLog(@"%@", received);
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMGRDoneNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], MGMSaveLastDate, nil]];
	[self close];
}
@end