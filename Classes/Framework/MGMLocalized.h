/*
 *  MGMLocalized.h
 *  GeckoReporter
 *
 *  Created by Mr. Gecko on 1/6/10.
 *  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
 *
 */

#define FRAMEWORKBUNDLE [NSBundle bundleWithIdentifier:@"com.MrGeckosMedia.GeckoReporter"]
#define MGMLocalized(key,comment) NSLocalizedStringFromTableInBundle(key, @"GeckoReporter", FRAMEWORKBUNDLE, comment)