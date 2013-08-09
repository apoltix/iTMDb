//
//  TMDB.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMDBDelegate.h"
#import "TMDBMovie.h"
#import "TMDBError.h"
#import "TMDBConfiguration.h"

/**
 * A string value indicating the URL base of the API.
 */
extern NSString * const TMDBAPIURLBase;

/**
 * A string value indicating the version of the API to be used.
 */
extern NSString * const TMDBAPIVersion;

/**
 * A notification posted when a movie in this context finished loading. The
 * movie object is in the user info dictionary under the key
 * `TMDBMovieUserInfoKey`.
 */
extern NSString * const TMDBDidFinishLoadingMovieNotification;

/**
 * A notification posted when a movie in this context failed loading. The
 * movie object is in the user info dictionary under the key
 * `TMDBMovieUserInfoKey`. The user info also includes an error object under the
 * key `TMDBErrorUserInfoKey` when available.
 */
extern NSString * const TMDBDidFailLoadingMovieNotification;

extern NSString * const TMDBMovieUserInfoKey;
extern NSString * const TMDBErrorUserInfoKey;

/**
 * A `TMDB` instance is used as the TMDb context for all requests to the TMDb
 * API. You can create multiple independent instances if you wish. All objects
 * created by an instance references its creator object.
 */
@interface TMDB : NSObject

/** The delegate of the context. Optional. */
@property (nonatomic, weak) id<TMDBDelegate> delegate;

/** The API key used by the context. Required. */
@property (nonatomic, copy) NSString *apiKey;

/** The language used by the context. Default `@"en"` (English). Optional. */
@property (nonatomic, copy) NSString *language;

/** @name Creating an Instance */

/**
 * Initializes the context with the provided API key (required), and optionally
 * a delegate and language.
 */
- (instancetype)initWithAPIKey:(NSString *)anApiKey delegate:(id<TMDBDelegate>)aDelegate language:(NSString *)aLanguage;

/** @name Deprecated methods */

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

/** @name Getting Configuration */

@property (nonatomic, strong, readonly) TMDBConfiguration *configuration;

@end