//
//  DMSettingsManager.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 16/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DMSettingsManager.h"

@interface DMSettingsManager ()

@property (nonatomic, copy) NSDictionary *namedSettings;

@end

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
	NSMutableDictionary *ns = [NSMutableDictionary dictionary];

	NSURL *url = [[NSBundle mainBundle] URLForResource:@"Settings" withExtension:@"plist"];
	NSArray *rawSettings = [NSArray arrayWithContentsOfURL:url];

	for (NSDictionary *d in rawSettings) {
		DMSettingsItem *item = [[DMSettingsItem alloc] initWithDictionary:d];
		[s addObject:item];
		ns[item.name] = item;
	}

	[self willChangeValueForKey:@"settings"];
	[self willChangeValueForKey:@"namedSettings"];
	_settings = [s copy];
	_namedSettings = [ns copy];
	[self willChangeValueForKey:@"namedSettings"];
	[self didChangeValueForKey:@"settings"];
}

- (DMSettingsItem *)settingsItemNamed:(NSString *)name {
	return _namedSettings[name];
}

@end
