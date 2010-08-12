//
//  MGMReportWindow.h
//  GeckoReporter
//
//  Created by Mr. Gecko on 12/27/09.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMSender;

extern NSString * const MGMSaveLastDate;

@interface MGMReportWindow : NSObject {
	IBOutlet NSMenu *mainMenu;
	IBOutlet NSMenuItem *hideMenu;
	IBOutlet NSMenuItem *quitMenu;
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSTextField *titleField;
	IBOutlet NSTextField *dateField;
	IBOutlet NSTextView *userReportView;
	IBOutlet NSTextField *userEmailField;
	IBOutlet NSButton *sendButton;
	IBOutlet NSButton *sendAllButton;
	IBOutlet NSButton *ignoreButton;
	IBOutlet NSButton *ignoreAllButton;
	NSString *reportFile;
	NSDate *reportDate;
	MGMSender *mailSender;
	
	NSMenu *appMainMenu;
}
+ (id)sharedWindowWithReport:(NSString *)theReportFile reportDate:(NSDate *)theReportDate;
- (id)initWithReport:(NSString *)theReportFile reportDate:(NSDate *)theReportDate;
- (void)setButtonsEnabled:(BOOL)flag;
- (void)close;
- (IBAction)sendReport:(id)sender;
- (IBAction)sendAllReports:(id)sender;
- (IBAction)ignoreReport:(id)sender;
- (IBAction)ignoreAllReports:(id)sender;
@end