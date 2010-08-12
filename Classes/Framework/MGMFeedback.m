//
//  MGMFeedback.m
//  GeckoReporter
//
//  Created by Mr. Gecko on 1/2/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMFeedback.h"
#import "MGMBugWindow.h"
#import "MGMContactWindow.h"

@implementation MGMFeedback
- (IBAction)openBugReport:(id)sender {
	[MGMBugWindow sharedBugWindow];
}
- (IBAction)openContact:(id)sender {
	[MGMContactWindow sharedContactWindow];
}
@end
