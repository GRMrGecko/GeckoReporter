//
//  MGMContactWindow.h
//  GeckoReporter
//
//  Created by Mr. Gecko on 1/3/10.
//  Copyright 2010 by Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
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
- (void)setButtonsEnabled:(BOOL)flag;
- (void)close;
- (IBAction)send:(id)sender;
- (IBAction)cancel:(id)sender;
@end
