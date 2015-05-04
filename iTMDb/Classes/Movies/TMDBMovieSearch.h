//
//  TMDBMovieSearch.h
//  iTMDb
//
//  Created by Christian Rasmussen on 25/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

@import Foundation;
#import "TMDBMovie.h"

typedef void (^TMDBMoviesFetchCompletionBlock)(NSArray /* TMDBMovie * */ *movies, NSError *error);

@interface TMDBMovieSearch : NSObject

+ (NSURL *)fetchURLWithMovieID:(NSUInteger)tmdbID options:(TMDBMovieFetchOptions)options;

+ (NSURL *)searchURLWithMovieTitle:(NSString *)title year:(NSUInteger)year;

#pragma mark - Searching
/** @name Searching */

+ (void)moviesWithTitle:(NSString *)title completion:(TMDBMoviesFetchCompletionBlock)completionBlock;

+ (void)moviesWithTitle:(NSString *)title year:(NSUInteger)year completion:(TMDBMoviesFetchCompletionBlock)completionBlock;

@end
