//
//  DMSettingsManager.h
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 16/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DMSetting) {
	DMSettingNone = -1,
	DMSettingAPIKey = 0,
	DMSettingRequestMovieID,
	DMSettingRequestMovieTitle,
	DMSettingRequestMovieYear,
	DMSettingRequestLanguage,
	DMSettingRequestFetchData,
	DMSettingRequestFetchDataBasicInformation,
	DMSettingRequestFetchDataCastAndCrew,
	DMSettingRequestFetchDataKeywords,
	DMSettingRequestFetchDataImageURLs
};

/*
	DMSettingResponseTitle,
	DMSettingResponseOverview,
	DMSettingResponseKeywords,
	DMSettingResponseReleaseDate,
	DMSettingResponseRuntime,
	DMSettingResponsePosters,
	DMSettingResponseBackdrops,
*/

@interface DMSettingsManager : NSObject

+ (instancetype)sharedManager;

- (id)valueForSetting:(DMSetting)setting;
- (void)setValue:(id)value forSetting:(DMSetting)setting;

- (NSString *)localizedStringForSetting:(DMSetting)setting;

@end
