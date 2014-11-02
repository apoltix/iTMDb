//
//  TMDBMovieSearch.h
//  iTMDb
//
//  Created by Christian Rasmussen on 25/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMDBMovie.h"

typedef void (^TMDBMoviesFetchCompletionBlock)(NSArray /* TMDBMovie * */ *movies, NSError *error);

@interface TMDBMovieSearch : NSObject

+ (NSURL *)fetchURLWithMovieID:(NSUInteger)tmdbID options:(TMDBMovieFetchOptions)options;

+ (NSURL *)fetchURLWithMovieTitle:(NSString *)title options:(TMDBMovieFetchOptions)options;

#pragma mark - Searching
/** @name Searching */

+ (void)moviesWithTitle:(NSString *)title options:(TMDBMovieFetchOptions)options completion:(TMDBMoviesFetchCompletionBlock)completionBlock;

+ (void)moviesWithTitle:(NSString *)title year:(NSUInteger)year options:(TMDBMovieFetchOptions)options completion:(TMDBMoviesFetchCompletionBlock)completionBlock;

@end
