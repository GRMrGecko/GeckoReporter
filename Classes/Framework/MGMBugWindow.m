//
//  MGMBugWindow.m
//  GeckoReporter
//
//  Created by Mr. Gecko on 1/2/10.
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

#import "MGMBugWindow.h"
#import "MGMReporter.h"
#import "MGMSender.h"
#import "MGMLocalized.h"
#import "MGMSystemInfo.h"
#import "MGMLog.h"

@implementation MGMBugWindow
+ (id)sharedBugWindow {
	return [[self alloc] init];
}
- (id)init {
	if ((self = [super init])) {
		if (![NSBundle loadNibNamed:@"MGMBugWindow" owner:self]) {
			[self release];
			self = nil;
		} else {
			NSUserDefaults *userDefautls = [NSUserDefaults standardUserDefaults];
			if ([userDefautls objectForKey:MGMGRUserEmail])
				[userEmailField setStringValue:[userDefautls objectForKey:MGMGRUserEmail]];
			
			[mainWindow makeKeyAndOrderFront:self];
			MGMSystemInfo *sysInfo = [MGMSystemInfo info];
			if ([sysInfo isUIElement])
				[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		}
		
	}
	return self;
}

- (void)dealloc {
	MGMLog(@"%s Releasing", __PRETTY_FUNCTION__);
	[mailSender release];
	[mainWindow release];
	[super dealloc];
	self = nil;
}

- (void)setButtonsEnabled:(BOOL)flag {
	[sendButton setEnabled:flag];
	[cancelButton setEnabled:flag];
}

- (void)close {
	[mainWindow orderOut:self];
	[self release];
}

- (IBAction)send:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[userEmailField stringValue] forKey:MGMGRUserEmail];
	if (mailSender==nil) {
		mailSender = [MGMSender new];
		[mailSender sendBug:[[bugView textStorage] string] reproduce:[[reproduceView textStorage] string] delegate:self];
	}
	[sendButton setTitle:MGMLocalized(@"Sending...", nil)];
	[self setButtonsEnabled:NO];
}
- (IBAction)cancel:(id)sender {
	[self close];
}

- (void)sendError:(NSError *)error {
	NSAlert *theAlert = [[NSAlert new] autorelease];
	[theAlert addButtonWithTitle:MGMLocalized(@"Ok", nil)];
	[theAlert setMessageText:MGMLocalized(@"Error could not send bug report.", nil)];
	[theAlert setInformativeText:[error localizedDescription]];
	[theAlert setAlertStyle:2];
	[theAlert runModal];
	[self setButtonsEnabled:YES];
}

- (void)sendFinished:(NSString *)received {
	MGMLog(@"%@", received);
	[self close];
}
@end