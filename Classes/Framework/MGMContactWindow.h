//
//  MGMContactWindow.h
//  GeckoReporter
//
//  Created by Mr. Gecko on 1/3/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMSender;

@interface MGMContactWindow : NSObject {
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSTextView *messageView;
	IBOutlet NSTextField *userEmailField;
	IBOutlet NSTextField *userNameField;
	IBOutlet NSPopUpButton *subjectPopUp;
	IBOutlet NSButton *sendButton;
	IBOutlet NSButton *cancelButton;
	MGMSender *mailSender;
}
+ (id)sharedContactWindow;
- (void)setButtonsEnabled:(BOOL)flag;
- (void)close;
- (IBAction)send:(id)sender;
- (IBAction)cancel:(id)sender;
@end
