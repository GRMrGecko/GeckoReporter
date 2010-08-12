//
//  MGMController.m
//  GeckoReporter
//
//  Created by Mr. Gecko on 1/1/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMController.h"
#import <GeckoReporter/GeckoReporter.h>

@implementation MGMController
- (void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setup) name:MGMGRDoneNotification object:nil];
	[MGMReporter sharedReporter];
}
- (void)setup {
	[mainWindow makeKeyAndOrderFront:self];
}
- (IBAction)crashApplication:(id)sender {
	NSLog(@"This should crash this application %@", 1234567890);
}
- (IBAction)RemoveLastDate:(id)sender {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:MGMGRLastCrashDate];
}
- (IBAction)RemoveSendAll:(id)sender {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:MGMGRSendAll];
}
- (IBAction)RemoveIgnoreAll:(id)sender {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:MGMGRIgnoreAll];
}
@end
