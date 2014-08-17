//
//  DMSettingsManager.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 16/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DMSettingsManager.h"

@implementation DMSettingsManager

+ (instancetype)sharedManager {
	static DMSettingsManager *sharedManager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedManager = [[self alloc] init];
	});
	return sharedManager;
}

- (instancetype)init {
	if (!(self = [super init])) {
		return nil;
	}

	[self loadSettings];

	return self;
}

- (void)loadSettings {
	NSMutableArray *s = [NSMutableArray array];

	NSURL *url = [[NSBundle mainBundle] URLForResource:@"Settings" withExtension:@"plist"];
	NSArray *rawSettings = [NSArray arrayWithContentsOfURL:url];

	for (NSDictionary *d in rawSettings) {
		DMSettingsItem *item = [[DMSettingsItem alloc] initWithDictionary:d];
		[s addObject:item];
	}

	[self willChangeValueForKey:@"settings"];
	_settings = [s copy];
	[self didChangeValueForKey:@"settings"];
}

@end
