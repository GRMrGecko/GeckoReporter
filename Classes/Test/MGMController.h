//
//  MGMController.h
//  GeckoReporter
//
//  Created by Mr. Gecko on 1/1/10.
//  Copyright 2010 by Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@interface MGMController : NSObject {
	IBOutlet NSWindow *mainWindow;
	NSString *crashString;
}
- (IBAction)crashApplication:(id)sender;
- (IBAction)RemoveLastDate:(id)sender;
- (IBAction)RemoveSendAll:(id)sender;
- (IBAction)RemoveIgnoreAll:(id)sender;
@end
