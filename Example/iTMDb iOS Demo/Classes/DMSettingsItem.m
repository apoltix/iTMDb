//
//  DMSettingsItem.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 17/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DMSettingsItem.h"

@implementation DMSettingsItem

+ (DMSettingsItemType)settingsItemTypeFromString:(NSString *)s {
	if (s == nil) {
		return DMSettingsItemTypeNone;
	}

	static NSDictionary *mapping;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		mapping = @{
			@"string": @(DMSettingsItemTypeString),
			@"integer": @(DMSettingsItemTypeInteger),
			@"bool": @(DMSettingsItemTypeBool)
		};
	});
	return [mapping[s] unsignedIntegerValue];
}

- (instancetype)initWithDictionary:(NSDictionary *)d {
	if (!(self = [super init])) {
		return nil;
	}

	_name = d[@"name"];
	_type = [DMSettingsItem settingsItemTypeFromString:d[@"type"]];
	_maxLength = [((NSNumber *)d[@"maxLength"] ? : @(NSUIntegerMax)) unsignedIntegerValue];

	NSAssert(_name != nil, @"Name must not be nil.");
	NSAssert([_name isKindOfClass:[NSString class]], @"Name must be a string.");
	NSAssert(_type != DMSettingsItemTypeNone, @"Type must be supported.");

	[self loadValue];

	return self;
}

#pragma mark - Getters and Setters

- (NSString *)localizedName {
	return NSLocalizedString(self.name,);
}

- (void)loadValue {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	switch (self.type) {
		case DMSettingsItemTypeString: {
			_value = [defaults objectForKey:self.name];
		} break;
		case DMSettingsItemTypeInteger: {
			_value = @([defaults integerForKey:self.name]);
		} break;
		case DMSettingsItemTypeBool: {
			_value = @([defaults boolForKey:self.name]);
		} break;
		case DMSettingsItemTypeNone: {
			_value = nil;
			NSAssert(NO, @"Unsupported type.");
		} break;
	}
}

- (void)setValue:(id)value {
	_value = value;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	switch (self.type) {
		case DMSettingsItemTypeString: {
			[defaults setObject:value forKey:self.name];
		} break;
		case DMSettingsItemTypeInteger: {
			[defaults setInteger:[(NSNumber *)value integerValue] forKey:self.name];
		} break;
		case DMSettingsItemTypeBool: {
			[defaults setBool:[(NSNumber *)value boolValue] forKey:self.name];
		} break;
		case DMSettingsItemTypeNone: {
			NSAssert(NO, @"Unsupported type.");
		} break;
	}
}

@end
