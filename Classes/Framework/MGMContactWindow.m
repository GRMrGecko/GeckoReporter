//
//  MGMContactWindow.m
//  GeckoReporter
//
//  Created by Mr. Gecko on 1/3/10.
//  Copyright 2010 by Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMContactWindow.h"
#import "MGMReporter.h"
#import "MGMSender.h"
#import "MGMLocalized.h"
#import "MGMLog.h"

@implementation MGMContactWindow
+ (id)new {
	return [[self alloc] init];
}
- (id)init {
	if (self = [super init]) {
		if (![NSBundle loadNibNamed:@"MGMContactWindow" owner:self]) {
			[self release];
			self = nil;
		} else {
			NSUserDefaults *userDefautls = [NSUserDefaults standardUserDefaults];
			if ([userDefautls objectForKey:MGMGRUserEmail])
				[userEmailField setStringValue:[userDefautls objectForKey:MGMGRUserEmail]];
			if ([userDefautls objectForKey:MGMGRUserName])
				[userNameField setStringValue:[userDefautls objectForKey:MGMGRUserName]];
			
			[mainWindow makeKeyAndOrderFront:self];
		}
		
	}
	return self;
}

- (void)dealloc {
	MGMLog(@"%s Releasing", __PRETTY_FUNCTION__);
	if (mailSender!=nil)
		[mailSender release];
	if (mainWindow!=nil)
		[mainWindow release];
	[super dealloc];
}

- (void)setButtonsEnabled:(BOOL)flag {
	[sendButton setEnabled:flag];
	[cancelButton setEnabled:flag];
}

- (void)close {
	[mainWindow orderOut:self];
	[self release];
	self = nil;
}

- (IBAction)send:(id)sender {
	if ([[userEmailField stringValue] isEqualToString:@""] || [[userNameField stringValue] isEqualToString:@""]) {
		NSAlert *theAlert = [[NSAlert new] autorelease];
		[theAlert addButtonWithTitle:MGMLocalized(@"Ok", nil)];
		[theAlert setMessageText:MGMLocalized(@"Fields not filled.", nil)];
		[theAlert setInformativeText:MGMLocalized(@"Please be sure all fields are filled as all fields are required.", nil)];
		[theAlert setAlertStyle:2];
		[theAlert runModal];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:[userEmailField stringValue] forKey:MGMGRUserEmail];
		[[NSUserDefaults standardUserDefaults] setObject:[userNameField stringValue] forKey:MGMGRUserName];
		if (mailSender==nil) {
			mailSender = [[MGMSender new] retain];
			[mailSender sendMessage:[[messageView textStorage] string] subject:[subjectPopUp titleOfSelectedItem] delegate:self];
		}
		[sendButton setTitle:MGMLocalized(@"Sending...", nil)];
		[self setButtonsEnabled:NO];
	}
}
- (IBAction)cancel:(id)sender {
	[self close];
}

- (void)sendError:(NSError *)error {
	NSAlert *theAlert = [[NSAlert new] autorelease];
	[theAlert addButtonWithTitle:MGMLocalized(@"Ok", nil)];
	[theAlert setMessageText:MGMLocalized(@"Error could not send message.", nil)];
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