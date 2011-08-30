//
//  MGMSender.h
//  GeckoReporter
//
//  Created by Mr. Gecko on 12/28/09.
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

#import "MGMSender.h"
#import "MGMReporter.h"
#import "MGMSystemInfo.h"
#import "MGMLocalized.h"
#import "MGMLog.h"

NSString * const MGMDefaultTimeZone = @"GMT";
NSString * const MGMDefaultTimeFormat = @"%a, %m/%d/%y %H:%M:%S %Z";
NSString * const MGMDefaultCrashEmail = @"crashreports@mrgeckosmedia.com";
NSString * const MGMDefaultBugsEmail = @"bugs@mrgeckosmedia.com";
NSString * const MGMDefaultContactEmail = @"support@mrgeckosmedia.com";
NSString * const MGMDefaultURL = @"http://mrgeckosmedia.com/sendreport.php";

NSString * const MGMGRTimeZone = @"MGMGRTimeZone";
NSString * const MGMGRTimeFormat = @"MGMGRTimeFormat";
NSString * const MGMGRReportFileAttached = @"MGMGRReportFileAttached";
NSString * const MGMGRCrashEmail = @"MGMGRCrashEmail";
NSString * const MGMGRBugsEmail = @"MGMGRBugsEmail";
NSString * const MGMGRContactEmail = @"MGMGRContactEmail";
NSString * const MGMGRURL = @"MGMGRURL";
NSString * const MGMGRLogFiles = @"MGMGRLogFiles";

NSString * const MGMGRFPath = @"path";
NSString * const MGMGRFName = @"name";

@interface MGMSender (MGMPrivate)
- (NSData *)buildBodyWithObjects:(NSDictionary *)theObjects boundary:(NSString *)theBoundary;
- (NSDictionary *)defaultObjects;
@end

@implementation MGMSender
- (void)dealloc {
#if MGMGRReleaseDebug
	MGMLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[theConnection release];
	[receivedData release];
	[super dealloc];
}

- (NSData *)buildBodyWithObjects:(NSDictionary *)theObjects boundary:(NSString *)theBoundary {
	NSMutableData *data = [NSMutableData data];
	NSArray *keys = [theObjects allKeys];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *timeZone, *timeFormat;
	if ([userDefaults objectForKey:MGMGRTimeZone]!=nil && ![[userDefaults objectForKey:MGMGRTimeZone] isEqualToString:@""]) {
		timeZone = [userDefaults objectForKey:MGMGRTimeZone];
	} else if ([infoDictionary objectForKey:MGMGRTimeZone]!=nil && ![[infoDictionary objectForKey:MGMGRTimeZone] isEqualToString:@""]) {
		timeZone = [infoDictionary objectForKey:MGMGRTimeZone];
	} else {
		timeZone = MGMDefaultTimeZone;
	}
	if ([userDefaults objectForKey:MGMGRTimeFormat]!=nil && ![[userDefaults objectForKey:MGMGRTimeFormat] isEqualToString:@""]) {
		timeFormat = [userDefaults objectForKey:MGMGRTimeFormat];
	} else if ([infoDictionary objectForKey:MGMGRTimeFormat]!=nil && ![[infoDictionary objectForKey:MGMGRTimeFormat] isEqualToString:@""]) {
		timeFormat = [infoDictionary objectForKey:MGMGRTimeFormat];
	} else {
		timeFormat = MGMDefaultTimeFormat;
	}
	
	for (int i=0; i<[keys count]; i++) {
		NSString *key = [keys objectAtIndex:i];
		id object = [theObjects objectForKey:key];
		[data appendData:[[NSString stringWithFormat:@"--%@\r\n", theBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
		if ([object isKindOfClass:[NSString class]]) {
			[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:[object dataUsingEncoding:NSUTF8StringEncoding]];
		} else if ([object isKindOfClass:[NSNumber class]]) {
			[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:[[object stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
		} else if ([object isKindOfClass:[NSData class]]) {
			[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:object];
		} else if ([object isKindOfClass:[NSDate class]]) {
			[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
			NSDateFormatter *dateFormatter = [NSDateFormatter new];
			[dateFormatter setDateFormat:timeFormat];
			if ([timeZone length]==3) {
				[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:timeZone]];
			} else {
				[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:timeZone]];
			}
			NSString *date = [dateFormatter stringFromDate:object];
			[dateFormatter release];
			[data appendData:[date dataUsingEncoding:NSUTF8StringEncoding]];
		} else if ([object isKindOfClass:[NSURL class]]) {
			[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
			[data appendData:[[object absoluteString] dataUsingEncoding:NSUTF8StringEncoding]];
		} else if ([object isKindOfClass:[NSDictionary class]]) {
			if ([manager fileExistsAtPath:[object objectForKey:MGMGRFPath]] && [manager isReadableFileAtPath:[object objectForKey:MGMGRFPath]]) {
				[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, [object objectForKey:MGMGRFName]] dataUsingEncoding:NSUTF8StringEncoding]];
				NSString *mimeString = @"application/octet-stream";
				CFStringRef extentionInfo = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[[object objectForKey:MGMGRFPath] pathExtension], CFSTR("public.data"));
				if (extentionInfo!=NULL) {
					CFStringRef mime = UTTypeCopyPreferredTagWithClass(extentionInfo, kUTTagClassMIMEType);
					CFRelease(extentionInfo);
					if (mime!=NULL) {
						mimeString = [(NSString *)mime autorelease];
					}
				}
				[data appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", mimeString] dataUsingEncoding:NSUTF8StringEncoding]];
				[data appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
				[data appendData:[NSData dataWithContentsOfFile:[object objectForKey:MGMGRFPath]]];
			}
		}
		[data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[data appendData:[[NSString stringWithFormat:@"--%@--", theBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	return data;
}
- (NSDictionary *)defaultObjects {
	MGMSystemInfo *sysInfo = [MGMSystemInfo info];
	NSMutableDictionary *objects = [NSMutableDictionary dictionary];
	[objects setObject:[sysInfo frameworkVersion] forKey:@"GRVersion"];
	[objects setObject:[sysInfo applicationName] forKey:@"Application"];
	[objects setObject:[sysInfo applicationIdentifier] forKey:@"Application Identifier"];
	[objects setObject:[sysInfo applicationVersion] forKey:@"Application Version"];
	[objects setObject:[sysInfo language] forKey:@"Language"];
	[objects setObject:[NSString stringWithFormat:@"%@ %@", [sysInfo architecture], [sysInfo CPUFamily]] forKey:@"System Architecture"];
	[objects setObject:[NSNumber numberWithInt:[sysInfo CPUCount]] forKey:@"CPU Count"];
	[objects setObject:[sysInfo modelName] forKey:@"Model Name"];
	[objects setObject:[sysInfo model] forKey:@"Model"];
	[objects setObject:[NSString stringWithFormat:@"%@ %@", [sysInfo OSVersion], [sysInfo OSVersionName]] forKey:@"System Version"];
	double CPUMHz = (double)[sysInfo CPUMHz];
	NSString *CPUFreq = @"MHz";
	if (CPUMHz>=1000) {
		CPUFreq = @"GHz";
		CPUMHz /= 1000;
		if (CPUMHz>=1000) {
			CPUFreq = @"THz";
			CPUMHz /= 1000;
		}
	}
	[objects setObject:[NSString stringWithFormat:@"%.2f %@", CPUMHz, CPUFreq] forKey:@"CPU Speed"];
	double RAMSize = (double)[sysInfo RAMSize];
	NSString *RAMType = @"MB";
	if (RAMSize>=1024) {
		RAMType = @"GB";
		RAMSize /= 1024;
		if (RAMSize>=1024) {
			RAMType = @"TB";
			RAMSize /= 1024;
		}
	}
	[objects setObject:[NSString stringWithFormat:@"%.2f %@", RAMSize, RAMType] forKey:@"RAM Size"];
	
	return objects;
}
- (void)sendReport:(NSString *)theReportPath reportDate:(NSDate *)theReportDate userReport:(NSString *)theUserReport delegate:(id)theDelegate {
	delegate = theDelegate;
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	MGMSystemInfo *sysInfo = [MGMSystemInfo info];
	
	NSString *email = nil, *url = nil, *userEmail = nil, *logFiles = nil;
	BOOL reportAttached = NO;
	if ([userDefaults objectForKey:MGMGRCrashEmail]!=nil && ![[userDefaults objectForKey:MGMGRCrashEmail] isEqualToString:@""]) {
		email = [userDefaults objectForKey:MGMGRCrashEmail];
	} else if ([infoDictionary objectForKey:MGMGRCrashEmail]!=nil && ![[infoDictionary objectForKey:MGMGRCrashEmail] isEqualToString:@""]) {
		email = [infoDictionary objectForKey:MGMGRCrashEmail];
	} else if ([userDefaults objectForKey:MGMGRBugsEmail]!=nil && ![[userDefaults objectForKey:MGMGRBugsEmail] isEqualToString:@""]) {
		email = [userDefaults objectForKey:MGMGRBugsEmail];
	} else if ([infoDictionary objectForKey:MGMGRBugsEmail]!=nil && ![[infoDictionary objectForKey:MGMGRBugsEmail] isEqualToString:@""]) {
		email = [infoDictionary objectForKey:MGMGRBugsEmail];
	} else if ([userDefaults objectForKey:MGMGRContactEmail]!=nil && ![[userDefaults objectForKey:MGMGRContactEmail] isEqualToString:@""]) {
		email = [userDefaults objectForKey:MGMGRContactEmail];
	} else if ([infoDictionary objectForKey:MGMGRContactEmail]!=nil && ![[infoDictionary objectForKey:MGMGRContactEmail] isEqualToString:@""]) {
		email = [infoDictionary objectForKey:MGMGRContactEmail];
	} else {
		email = MGMDefaultCrashEmail;
	}
	if ([userDefaults objectForKey:MGMGRURL]!=nil && ![[userDefaults objectForKey:MGMGRURL] isEqualToString:@""]) {
		url = [userDefaults objectForKey:MGMGRURL];
	} else if ([infoDictionary objectForKey:MGMGRURL]!=nil && ![[infoDictionary objectForKey:MGMGRURL] isEqualToString:@""]) {
		url = [infoDictionary objectForKey:MGMGRURL];
	} else {
		url = MGMDefaultURL;
	}
	if ([userDefaults objectForKey:MGMGRUserEmail]!=nil && ![[userDefaults objectForKey:MGMGRUserEmail] isEqualToString:@""]) {
		userEmail = [userDefaults objectForKey:MGMGRUserEmail];
	}
	if ([userDefaults objectForKey:MGMGRReportFileAttached]!=nil) {
		reportAttached = [[userDefaults objectForKey:MGMGRReportFileAttached] boolValue];
	} else if ([infoDictionary objectForKey:MGMGRReportFileAttached]!=nil) {
		reportAttached = [[infoDictionary objectForKey:MGMGRReportFileAttached] boolValue];
	}
	if ([userDefaults objectForKey:MGMGRLogFiles]!=nil && ![[userDefaults objectForKey:MGMGRLogFiles] isEqualToString:@""]) {
		logFiles = [userDefaults objectForKey:MGMGRLogFiles];
	} else if ([infoDictionary objectForKey:MGMGRLogFiles]!=nil && ![[infoDictionary objectForKey:MGMGRLogFiles] isEqualToString:@""]) {
		logFiles = [infoDictionary objectForKey:MGMGRLogFiles];
	}
	
	srandomdev();
	NSString *boundary = [NSString stringWithFormat:@"----Boundary+%d", random()%100000];
	
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary, nil] forHTTPHeaderField:@"Content-Type"];
	
	
	NSMutableDictionary *objects = [NSMutableDictionary dictionaryWithDictionary:[self defaultObjects]];
	[objects setObject:@"crash" forKey:@"GRType"];
	if (email!=nil)
		[objects setObject:email forKey:@"GREmail"];
	[objects setObject:[NSString stringWithFormat:@"Crash Report for %@", [sysInfo applicationName]] forKey:@"GRSubject"];
	[objects setObject:(reportAttached ? @"YES" : @"NO") forKey:@"GRReportAttached"];
	if (theUserReport!=nil)
		[objects setObject:theUserReport forKey:@"GRUserReport"];
	if (userEmail!=nil)
		[objects setObject:userEmail forKey:@"User Email Address"];
	if (theReportDate!=nil)
		[objects setObject:theReportDate forKey:@"Crash Report Date"];
	if (theReportPath!=nil && ![theReportPath isEqualToString:@""])
		[objects setObject:[NSDictionary dictionaryWithObjectsAndKeys:theReportPath, MGMGRFPath, [NSString stringWithFormat:@"%@.crash", [[MGMSystemInfo info] applicationName]], MGMGRFName, nil] forKey:@"reportFile"];
	if (logFiles!=nil && ![logFiles isEqualToString:@""]) {
		NSArray *logs = [logFiles componentsSeparatedByString:@" "];
		for (int i=0; i<[logs count]; i++) {
			NSString *file = [[logs objectAtIndex:i] stringByExpandingTildeInPath];
			[objects setObject:[NSDictionary dictionaryWithObjectsAndKeys:file, MGMGRFPath, [file lastPathComponent], MGMGRFName, nil] forKey:[NSString stringWithFormat:@"logFile%d", i]];
		}
	}
	[postRequest setHTTPBody:[self buildBodyWithObjects:objects boundary:boundary]];
	
	theConnection = [[NSURLConnection connectionWithRequest:postRequest delegate:self] retain];
	if (theConnection) {
		receivedData = [[NSMutableData data] retain];
	}
}
- (void)sendBug:(NSString *)theBug reproduce:(NSString *)theReproduce delegate:(id)theDelegate {
	delegate = theDelegate;
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	MGMSystemInfo *sysInfo = [MGMSystemInfo info];
	
	NSString *email = nil, *url = nil, *userEmail = nil;
	if ([userDefaults objectForKey:MGMGRBugsEmail]!=nil && ![[userDefaults objectForKey:MGMGRBugsEmail] isEqualToString:@""]) {
		email = [userDefaults objectForKey:MGMGRBugsEmail];
	} else if ([infoDictionary objectForKey:MGMGRBugsEmail]!=nil && ![[infoDictionary objectForKey:MGMGRBugsEmail] isEqualToString:@""]) {
		email = [infoDictionary objectForKey:MGMGRBugsEmail];
	} else if ([userDefaults objectForKey:MGMGRCrashEmail]!=nil && ![[userDefaults objectForKey:MGMGRCrashEmail] isEqualToString:@""]) {
		email = [userDefaults objectForKey:MGMGRCrashEmail];
	} else if ([infoDictionary objectForKey:MGMGRCrashEmail]!=nil && ![[infoDictionary objectForKey:MGMGRCrashEmail] isEqualToString:@""]) {
		email = [infoDictionary objectForKey:MGMGRCrashEmail];
	} else if ([userDefaults objectForKey:MGMGRContactEmail]!=nil && ![[userDefaults objectForKey:MGMGRContactEmail] isEqualToString:@""]) {
		email = [userDefaults objectForKey:MGMGRContactEmail];
	} else if ([infoDictionary objectForKey:MGMGRContactEmail]!=nil && ![[infoDictionary objectForKey:MGMGRContactEmail] isEqualToString:@""]) {
		email = [infoDictionary objectForKey:MGMGRContactEmail];
	} else {
		email = MGMDefaultBugsEmail;
	}
	if ([userDefaults objectForKey:MGMGRURL]!=nil && ![[userDefaults objectForKey:MGMGRURL] isEqualToString:@""]) {
		url = [userDefaults objectForKey:MGMGRURL];
	} else if ([infoDictionary objectForKey:MGMGRURL]!=nil && ![[infoDictionary objectForKey:MGMGRURL] isEqualToString:@""]) {
		url = [infoDictionary objectForKey:MGMGRURL];
	} else {
		url = MGMDefaultURL;
	}
	if ([userDefaults objectForKey:MGMGRUserEmail]!=nil && ![[userDefaults objectForKey:MGMGRUserEmail] isEqualToString:@""]) {
		userEmail = [userDefaults objectForKey:MGMGRUserEmail];
	}
	
	srandomdev();
	NSString *boundary = [NSString stringWithFormat:@"----Boundary+%d", random()%100000];
	
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary, nil] forHTTPHeaderField:@"Content-Type"];
	
	
	NSMutableDictionary *objects = [NSMutableDictionary dictionaryWithDictionary:[self defaultObjects]];
	[objects setObject:@"bug" forKey:@"GRType"];
	if (email!=nil)
		[objects setObject:email forKey:@"GREmail"];
	[objects setObject:[NSString stringWithFormat:@"Bug Report for %@", [sysInfo applicationName]] forKey:@"GRSubject"];
	if (userEmail!=nil)
		[objects setObject:userEmail forKey:@"User Email Address"];
	if (theBug!=nil)
		[objects setObject:theBug forKey:@"GRBug"];
	if (theReproduce!=nil)
		[objects setObject:theReproduce forKey:@"GRReproduce"];
	[postRequest setHTTPBody:[self buildBodyWithObjects:objects boundary:boundary]];
	
	theConnection = [[NSURLConnection connectionWithRequest:postRequest delegate:self] retain];
	if (theConnection) {
		receivedData = [[NSMutableData data] retain];
	}
}
- (void)sendMessage:(NSString *)theMessage subject:(NSString *)theSubject delegate:(id)theDelegate {
	if (theDelegate!=nil)
		delegate = theDelegate;
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	MGMSystemInfo *sysInfo = [MGMSystemInfo info];
	
	NSString *email = nil, *url = nil, *userEmail = nil, *userName = nil;
	if ([userDefaults objectForKey:MGMGRContactEmail]!=nil && ![[userDefaults objectForKey:MGMGRContactEmail] isEqualToString:@""]) {
		email = [userDefaults objectForKey:MGMGRContactEmail];
	} else if ([infoDictionary objectForKey:MGMGRContactEmail]!=nil && ![[infoDictionary objectForKey:MGMGRContactEmail] isEqualToString:@""]) {
		email = [infoDictionary objectForKey:MGMGRContactEmail];
	} else if ([userDefaults objectForKey:MGMGRBugsEmail]!=nil && ![[userDefaults objectForKey:MGMGRBugsEmail] isEqualToString:@""]) {
		email = [userDefaults objectForKey:MGMGRBugsEmail];
	} else if ([infoDictionary objectForKey:MGMGRBugsEmail]!=nil && ![[infoDictionary objectForKey:MGMGRBugsEmail] isEqualToString:@""]) {
		email = [infoDictionary objectForKey:MGMGRBugsEmail];
	} else if ([userDefaults objectForKey:MGMGRCrashEmail]!=nil && ![[userDefaults objectForKey:MGMGRCrashEmail] isEqualToString:@""]) {
		email = [userDefaults objectForKey:MGMGRCrashEmail];
	} else if ([infoDictionary objectForKey:MGMGRCrashEmail]!=nil && ![[infoDictionary objectForKey:MGMGRCrashEmail] isEqualToString:@""]) {
		email = [infoDictionary objectForKey:MGMGRCrashEmail];
	} else {
		email = MGMDefaultBugsEmail;
	}
	if ([userDefaults objectForKey:MGMGRURL]!=nil && ![[userDefaults objectForKey:MGMGRURL] isEqualToString:@""]) {
		url = [userDefaults objectForKey:MGMGRURL];
	} else if ([infoDictionary objectForKey:MGMGRURL]!=nil && ![[infoDictionary objectForKey:MGMGRURL] isEqualToString:@""]) {
		url = [infoDictionary objectForKey:MGMGRURL];
	} else {
		url = MGMDefaultURL;
	}
	if ([userDefaults objectForKey:MGMGRUserEmail]!=nil && ![[userDefaults objectForKey:MGMGRUserEmail] isEqualToString:@""]) {
		userEmail = [userDefaults objectForKey:MGMGRUserEmail];
	}
	if ([userDefaults objectForKey:MGMGRUserName]!=nil && ![[userDefaults objectForKey:MGMGRUserName] isEqualToString:@""]) {
		userName = [userDefaults objectForKey:MGMGRUserName];
	}
	
	srandomdev();
	NSString *boundary = [NSString stringWithFormat:@"----Boundary+%d", random()%100000];
	
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary, nil] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableDictionary *objects = [NSMutableDictionary dictionaryWithDictionary:[self defaultObjects]];
	[objects setObject:@"contact" forKey:@"GRType"];
	if (email!=nil)
		[objects setObject:email forKey:@"GREmail"];
	[objects setObject:[NSString stringWithFormat:@"%@ for %@", theSubject, [sysInfo applicationName]] forKey:@"GRSubject"];
	if (userEmail!=nil)
		[objects setObject:userEmail forKey:@"User Email Address"];
	if (userEmail!=nil)
		[objects setObject:userName forKey:@"User Name"];
	if (theMessage!=nil)
		[objects setObject:theMessage forKey:@"GRMessage"];
	[postRequest setHTTPBody:[self buildBodyWithObjects:objects boundary:boundary]];
	
	theConnection = [[NSURLConnection connectionWithRequest:postRequest delegate:self] retain];
	if (theConnection) {
		receivedData = [[NSMutableData data] retain];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	if ([response statusCode]!=200) {
		[connection cancel];
		NSError *error = [NSError errorWithDomain:@"com.MrGeckosMedia.GRStatus" code:1 userInfo:
						  [NSDictionary dictionaryWithObject:[NSString stringWithFormat:MGMLocalized(@"Status Code Returned %d", nil), [response statusCode]]
													  forKey:NSLocalizedDescriptionKey]];
		MGMLog(@"%@", [error localizedDescription]);
		if (delegate!=nil && [delegate respondsToSelector:@selector(sendError:)])
			[delegate sendError:error];
	} else {
		[receivedData setLength:0];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	MGMLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	if (delegate!=nil && [delegate respondsToSelector:@selector(sendError:)])
		[delegate sendError:error];
	[self release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (receivedData!=nil) {
		NSString *receivedString = [[[NSString alloc] initWithData:[NSData dataWithData:receivedData] encoding:NSUTF8StringEncoding] autorelease];
		if (delegate!=nil && [delegate respondsToSelector:@selector(sendFinished:)])
			[delegate sendFinished:receivedString];
	}
}
@end