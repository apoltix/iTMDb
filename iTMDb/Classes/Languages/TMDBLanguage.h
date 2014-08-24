//
//  TMDBLanguage.h
//  iTMDb
//
//  Created by Christian Rasmussen on 10/08/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMDBLanguage : NSObject

+ (NSArray *)languagesFromArrayOfDictionaries:(NSArray *)rawLanguagesDictionaries;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *iso639_1;

@end
