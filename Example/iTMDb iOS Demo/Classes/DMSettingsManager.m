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

+ (NSDictionary *)mapping
{
	static NSDictionary *mapping;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		mapping = @{
			@(DMSettingAPIKey): @"API Key",
			@(DMSettingRequestMovieID): @"Movie ID",
			@(DMSettingRequestMovieTitle): @"Movie Title",
			@(DMSettingRequestMovieYear): @"Movie Year",
			@(DMSettingRequestLanguage): @"Language",
			@(DMSettingRequestFetchData): @"Fetch Data",
			@(DMSettingRequestFetchDataBasicInformation): @"Basic Information",
			@(DMSettingRequestFetchDataCastAndCrew): @"Cast and Crew",
			@(DMSettingRequestFetchDataKeywords): @"Keywords",
			@(DMSettingRequestFetchDataImageURLs): @"Image URLs"
		};
	});
	return mapping;
}

#pragma mark - Getters and Setters

- (id)valueForSetting:(DMSetting)setting
{
	NSString *key = [DMSettingsManager mapping][@(setting)];
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)setValue:(id)value forSetting:(DMSetting)setting
{
	NSString *key = [DMSettingsManager mapping][@(setting)];
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

- (NSString *)localizedStringForSetting:(DMSetting)setting
{
	NSString *key = [DMSettingsManager mapping][@(setting)];
	return NSLocalizedString(key,);
}

@end
