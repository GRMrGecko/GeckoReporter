/*
 *  MGMLocalized.h
 *  GeckoReporter
 *
 *  Created by Mr. Gecko on 1/6/10.
 *  Copyright 2010 by Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
 *
 */

#define FRAMEWORKBUNDLE [NSBundle bundleWithIdentifier:@"com.MrGeckosMedia.GeckoReporter"]
#define MGMLocalized(key,comment) NSLocalizedStringFromTableInBundle(key, @"GeckoReporter", FRAMEWORKBUNDLE, comment)