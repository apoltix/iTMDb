//
//  TMDBLanguage.h
//  iTMDb
//
//  Created by Christian Rasmussen on 10/08/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

@import Foundation;

@interface TMDBLanguage : NSObject

+ (nonnull NSArray<TMDBLanguage *> *)languagesFromArrayOfDictionaries:(nonnull NSArray<NSDictionary *> *)rawLanguagesDictionaries;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, nullable, readonly) NSString *name;
@property (nonatomic, copy, nullable, readonly) NSString *iso639_1;

@end
