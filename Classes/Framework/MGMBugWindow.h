//
//  MGMBugWindow.h
//  GeckoReporter
//
//  Created by Mr. Gecko on 1/2/10.
//  Copyright 2010 by Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMSender;

@interface MGMBugWindow : NSObject {
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSTextView *bugView;
	IBOutlet NSTextView *reproduceView;
	IBOutlet NSTextField *userEmailField;
	IBOutlet NSButton *sendButton;
	IBOutlet NSButton *cancelButton;
	MGMSender *mailSender;
}
+ (id)sharedBugWindow;
- (void)setButtonsEnabled:(BOOL)flag;
- (void)close;
- (IBAction)send:(id)sender;
- (IBAction)cancel:(id)sender;
@end
