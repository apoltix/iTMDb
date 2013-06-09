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

@interface TMDB : NSObject

@property (nonatomic, weak) id<TMDBDelegate> delegate;
@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *language;

/** @name Creating an Instance */

/**
 * 
 */
- (id)initWithAPIKey:(NSString *)anApiKey delegate:(id<TMDBDelegate>)aDelegate language:(NSString *)aLanguage;

/** @name Notifications */
/**
 * 
 */
- (void)movieDidFinishLoading:(TMDBMovie *)aMovie;
/**
 * 
 */
- (void)movieDidFailLoading:(TMDBMovie *)aMovie error:(NSError *)error;

/** @name Convenience Methods */
/**
 * Fetches information about the movie with the given TMDb ID.
 *
 * @param anID The ID of the movie to fetch information about.
 * @return A TMDBMovie instance with the current information from the TMDb website.
 */
- (TMDBMovie *)movieWithID:(NSInteger)anID;

/**
 * Fetches information about the movie with the given name.
 *
 * As several movies share the same name, you can pass the year the movie was released to narrow down the search, e.g. "Charlotte's Web (2006)" to get the remake from 2006, rather than the original from 1973.
 *
 * @param aName The name of the movie to fetch information about.
 */
- (TMDBMovie *)movieWithName:(NSString *)aName;

@end