//
//  TMDB.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright (c) 2010 Devify. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TMDBMovie.h"
#import "TMDBError.h"
#import "TMDBConfiguration.h"

/**
 * A string value indicating the URL base of the API.
 */
extern NSString * const TMDBAPIURLBase;

/**
 * A string value indicating the version of the API used.
 */
extern NSString * const TMDBAPIVersion;

/**
 * The `TMDB` singleton instance is used as the TMDb context for all requests to
 * the TMDb API.
 */
@interface TMDB : NSObject

/** @name Getting the Shared Instance */

+ (instancetype)sharedInstance;

/** @name Context Settings */

/** The API key used by the context. Required. */
@property (nonatomic, copy) NSString *apiKey;

/** The language used by the context. Default `@"en"` (English). Optional. */
@property (nonatomic, copy) NSString *language;

/** @name Getting Configuration */

/** The TMDb configuration. */
@property (nonatomic, strong, readonly) TMDBConfiguration *configuration;

@end

@interface TMDB (UnavailableMethods)

/**
 * Fetches information about the movie with the given TMDb ID.
 *
 * @param anID The ID of the movie to fetch information about.
 * @return A TMDBMovie instance with the current information from the TMDb website.
 * @warning This method has been deprecated and removed as it doesn't follow
 * proper API design. Use `-[TMDBMovie movieWithID:options:context:]` instead.
 */
- (TMDBMovie *)movieWithID:(NSInteger)anID __attribute__((unavailable("This method has been deprecated and removed as it doesn't follow proper API design. Use `-[TMDBMovie movieWithID:options:context:]` instead.")));

/**
 * Fetches information about the movie with the given name.
 *
 * As several movies share the same name, you can pass the year the movie was released to narrow down the search, e.g. "Charlotte's Web (2006)" to get the remake from 2006, rather than the original from 1973.
 *
 * @param aName The name of the movie to fetch information about.
 * @warning This method has been deprecated and removed as it doesn't follow
 * proper API design. Use `-[TMDBMovie movieWithName:options:context:]` instead.
 */
- (TMDBMovie *)movieWithName:(NSString *)aName __attribute__((unavailable("This method has been deprecated and removed as it doesn't follow proper API design. Use `-[TMDBMovie movieWithName:options:context:]` instead.")));

@end