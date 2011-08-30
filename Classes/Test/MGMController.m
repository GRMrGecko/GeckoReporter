//
//  MGMController.m
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
