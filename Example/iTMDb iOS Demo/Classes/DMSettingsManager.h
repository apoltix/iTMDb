//
//  DMSettingsManager.h
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 16/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMSettingsItem.h"

@interface DMSettingsManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, copy, readonly) NSArray *settings;

- (DMSettingsItem *)settingsItemNamed:(NSString *)name;

@end
