//
//  TMDBLanguage.h
//  iTMDb
//
//  Created by Christian Rasmussen on 10/08/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMDB;

@interface TMDBLanguage : NSObject

+ (NSArray *)languagesFromArrayOfDictionaries:(NSArray *)rawLanguagesDictionaries context:(TMDB *)context;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary context:(TMDB *)context;

@property (nonatomic, strong, readonly) TMDB *context;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *iso639_1;

@end