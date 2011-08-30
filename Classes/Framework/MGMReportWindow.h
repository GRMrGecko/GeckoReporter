//
//  MGMReportWindow.h
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