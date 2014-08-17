//
//  DMSettingsItem.h
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 17/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DMSettingsItemType) {
	DMSettingsItemTypeNone,
	DMSettingsItemTypeString,
	DMSettingsItemTypeInteger,
	DMSettingsItemTypeBool
};

@interface DMSettingsItem : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *localizedName;

@property (nonatomic, readonly) DMSettingsItemType type;
@property (nonatomic, copy) id value;

@property (nonatomic, readonly) NSUInteger maxLength;

@end

@interface DMSettingsItem (Private)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
