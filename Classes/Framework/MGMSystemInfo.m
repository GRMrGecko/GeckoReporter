//
//  MGMSystemInfo.m
//  GeckoReporter
//
//  Created by Mr. Gecko on 12/31/09.
//  Copyright 2010 by Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMSystemInfo.h"
#import "MGMReporter.h"
#import "MGMLocalized.h"
#import "MGMLog.h"
#import <sys/sysctl.h>

#ifndef CPU_TYPE_ARM
#define CPU_TYPE_ARM		((cpu_type_t) 12)
#endif


NSString * const MGMCPUType = @"hw.cputype";
NSString * const MGM64Capable = @"hw.cpu64bit_capable";
NSString * const MGM64Bit = @"hw.optional.64bitops";
NSString * const MGMX8_664 = @"hw.optional.x86_64";
NSString * const MGMCPUFamily = @"hw.cpufamily";
NSString * const MGMCPUCount = @"hw.ncpu";
NSString * const MGMModel = @"hw.model";

@interface MGMSystemInfo (MGMPrivate)
- (int)valueFromSystem:(NSString *)theName;
- (NSString *)stringFromSystem:(NSString *)theName;
@end

@implementation MGMSystemInfo
+ (id)new {
	return [[[self alloc] init] autorelease];
}

- (int)valueFromSystem:(NSString *)theName {
	int value = 0;
	unsigned long length = sizeof(value);
	if (sysctlbyname([theName UTF8String], &value, &length, NULL, 0)==0) {
		return value;
	}
	return -1;
}
- (NSString *)stringFromSystem:(NSString *)theName {
	unsigned long length = sizeof(int);
	if (sysctlbyname([theName UTF8String], NULL, &length, NULL, 0)==0) {
		char *utf8String = (char *)malloc(sizeof(char) * length);
		if (sysctlbyname([theName UTF8String], utf8String, &length, NULL, 0)==0) {
			NSString *returnString = [NSString stringWithUTF8String:utf8String];
			if (utf8String!=NULL)
				free(utf8String);
			return returnString;
		}
		if (utf8String!=NULL)
			free(utf8String);
	}
	return nil;
}

- (NSString *)architecture {
	switch ([self valueFromSystem:MGMCPUType]) {
		case CPU_TYPE_MC680x0:
			return @"m68k";
			break;
		case CPU_TYPE_X86:
		case CPU_TYPE_X86_64:
			return @"Intel";
			break;
		case CPU_TYPE_POWERPC:
		case CPU_TYPE_POWERPC64:
			return @"PowerPC";
			break;
		case CPU_TYPE_ARM:
			return @"ARM";
			break;
	}
	return @"Unknown";
}

- (BOOL)is64Bit {
	int value = [self valueFromSystem:MGM64Capable];
	if (value==-1)
		value = [self valueFromSystem:MGM64Bit];
	if (value==-1)
		value = [self valueFromSystem:MGMX8_664];
	if (value==-1)
		value = 0;
	return (value==1);
}

- (NSString *)CPUFamily {
	switch ([self valueFromSystem:MGMCPUType]) {
		case CPU_TYPE_X86:
		case CPU_TYPE_X86_64:
			if ([self is64Bit]) {
				return @"Core 2 Duo";
			} else {
				if ([self CPUCount]==1)
					return @"Core Solo";
				else
					return @"Core Duo";
			}
			break;
		case CPU_TYPE_POWERPC:
		case CPU_TYPE_POWERPC64:
			switch ([self valueFromSystem:MGMCPUFamily]) {
				case CPUFAMILY_POWERPC_G3:
					return @"G3";
					break;
				case CPUFAMILY_POWERPC_G4:
					return @"G4";
					break;
				case CPUFAMILY_POWERPC_G5:
					return @"G5";
					break;
			}
			break;
	}
	return @"Unknown";
}

- (int)CPUCount {
	return [self valueFromSystem:MGMCPUCount];
}

- (NSString *)model {
	return [self stringFromSystem:MGMModel];
}

- (NSString *)modelName {
	NSString *model = [self stringFromSystem:MGMModel];
	NSDictionary *modelNames = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"ModelNames" ofType:@"plist"]];
	NSString *modelName = [modelNames objectForKey:model];
	if (modelName!=nil)
		return modelName;
	return model;
}

- (int)CPUMHz {
	SInt32 clockSpeed;
	if (Gestalt(gestaltProcClkSpeedMHz, &clockSpeed)==noErr) {
		return (int)clockSpeed;
	}
	return -1;
}

- (int)RAMSize {
	SInt32 ramSize;
	if (Gestalt(gestaltPhysicalRAMSizeInMegabytes, &ramSize)==noErr) {
		return (int)ramSize;
	}
	return -1;
}

- (int)OSMajorVersion {
	SInt32 majorVersion;
	if (Gestalt(gestaltSystemVersionMajor, &majorVersion)==noErr) {
		return (int)majorVersion;
	}
	return -1;
}
- (int)OSMinorVersion {
	SInt32 minorVersion;
	if (Gestalt(gestaltSystemVersionMinor, &minorVersion)==noErr) {
		return (int)minorVersion;
	}
	return -1;
}
- (int)OSBugFixVersion {
	SInt32 bugFixVersion;
	if (Gestalt(gestaltSystemVersionBugFix, &bugFixVersion)==noErr) {
		return (int)bugFixVersion;
	}
	return -1;
}
- (NSString *)OSVersion {
	int majorVersion = [self OSMajorVersion];
	int minorVersion = [self OSMinorVersion];
	int bugFixVersion = [self OSBugFixVersion];
	return [NSString stringWithFormat:@"%d.%d.%d", majorVersion, minorVersion, bugFixVersion];
}

- (NSString *)OSVersionName {
	if ([self OSMajorVersion]==10) {
		int minorVersion = [self OSMinorVersion];
		if (minorVersion==0)
			return @"Cheetah";
		if (minorVersion==1)
			return @"Puma";
		if (minorVersion==2)
			return @"Jaguar";
		if (minorVersion==3)
			return @"Panther";
		if (minorVersion==4)
			return @"Tiger";
		if (minorVersion==5)
			return @"Leopard";
		if (minorVersion==6)
			return @"Snow Leopard";
		if (minorVersion==7)
			return @"Garfield";
		if (minorVersion==8)
			return @"Liger";
	}
	return @"Unknown";
}

- (NSString *)language {
	NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
	if (languages!=nil && [languages count]>=1)
		return [languages objectAtIndex:0];
	return @"Unknown";
}

- (NSString *)applicationIdentifier {
	return [[NSBundle mainBundle] bundleIdentifier];
}

- (NSString *)applicationName {
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

- (NSString *)applicationEXECName {
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"];
}

- (NSString *)applicationVersion {
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (NSBundle *)frameworkBundle {
	return FRAMEWORKBUNDLE;
}

- (NSString *)frameworkVersion {
	return [FRAMEWORKBUNDLE objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (NSString *)useragentWithApplicationNameAndVersion:(NSString *)nameAndVersion {
	if (nameAndVersion==nil)
		nameAndVersion = [NSString stringWithFormat:@"%@/%@", [self applicationName], [self applicationVersion]];
	NSString *useragent = [NSString stringWithFormat:@"%@ (Macintosh; U; %@ ", nameAndVersion, [self architecture]];
	if ([self OSMajorVersion]==10)
		useragent = [useragent stringByAppendingString:@"Mac OS X "];
	else
		useragent = [useragent stringByAppendingString:@"Mac OS "];
	useragent = [useragent stringByAppendingFormat:@"%@; %@)", [self OSVersion], [self language]];
	return useragent;
}
- (NSString *)useragent {
	return [self useragentWithApplicationNameAndVersion:nil];
}
@end