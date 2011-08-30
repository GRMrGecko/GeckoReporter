//
//  MGMLog.m
//  GeckoReporter
//
//  Created by Mr. Gecko on 1/1/10.
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

#import "MGMLog.h"

@protocol NSFileManagerProtocol <NSObject>
- (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error;
- (NSDictionary *)fileSystemAttributesAtPath:(NSString *)path;

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;
- (BOOL)removeFileAtPath:(NSString *)path handler:(id)handler;

- (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error;
- (BOOL)movePath:(NSString *)source toPath:(NSString *)destination handler:(id)handler;
@end

static NSRecursiveLock *MGMLock = nil;

void MGMInitLock() {
	if (MGMLock==nil) {
		MGMLock = [NSRecursiveLock new];
    }
}

void MGMLogs(NSString *string) {
	MGMInitLock();
	[MGMLock lock];
	char *buffer;
	int length;
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	if (data!=nil) {
		buffer = (char *)[data bytes];
		length = [data length];
	} else {
		buffer = (char *)[string UTF8String];
		length = [string length];
	}
	NSFileManager<NSFileManagerProtocol> *manager = [NSFileManager defaultManager];
	fwrite(buffer, 1, length, stderr);
	NSString *applicationIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	NSString *logPath = [[NSString stringWithFormat:@"~/Library/Logs/%@.log", applicationIdentifier] stringByExpandingTildeInPath];
	NSString *log2Path = [[NSString stringWithFormat:@"~/Library/Logs/%@_2.log", applicationIdentifier] stringByExpandingTildeInPath];
	NSDictionary *attributes = nil;
	if ([manager respondsToSelector:@selector(attributesOfItemAtPath:error:)])
		attributes = [manager attributesOfItemAtPath:logPath error:nil];
	else
		attributes = [manager fileSystemAttributesAtPath:logPath];
	if ([[attributes objectForKey:NSFileSize] intValue]>=262144) {
		if ([manager fileExistsAtPath:log2Path]) {
			if ([manager respondsToSelector:@selector(removeItemAtPath:error:)])
				[manager removeItemAtPath:log2Path error:nil];
			else
				[manager removeFileAtPath:log2Path handler:nil];
		}
		if ([manager respondsToSelector:@selector(moveItemAtPath:toPath:error:)])
			[manager moveItemAtPath:logPath toPath:log2Path error:nil];
		else
			[manager movePath:logPath toPath:log2Path handler:nil];
	}
	FILE *logFile = fopen([logPath fileSystemRepresentation], "a");
	fwrite(buffer, 1, length, logFile);
	fclose(logFile);
	[MGMLock unlock];
}

void MGMLog(NSString *format, ...) {
	va_list ap;
	va_start(ap, format);
	MGMLogv(format, ap);
	va_end(ap);
}

void MGMLogv(NSString *format, va_list args) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	if (![format hasSuffix:@"\n"])
		format = [format stringByAppendingString:@"\n"];
	NSString *message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
	NSProcessInfo *procInfo = [NSProcessInfo processInfo];
	NSString *logString = [NSString stringWithFormat:@"%@ %@[%d] %@",
							[[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S.%F"],
							[procInfo processName],
							[procInfo processIdentifier],
							message
						   ];
	MGMLogs(logString);
	[pool drain];
}