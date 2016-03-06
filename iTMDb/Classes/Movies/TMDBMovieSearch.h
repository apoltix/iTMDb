//
//  TMDBMovieSearch.h
//  iTMDb
//
//  Created by Christian Rasmussen on 25/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

@import Foundation;
#import "TMDBMovie.h"

typedef void (^TMDBMoviesFetchCompletionBlock)(NSArray<TMDBMovie *> * _Nullable movies, NSError * _Nullable error);

@interface TMDBMovieSearch : NSObject

+ (nullable NSURL *)fetchURLWithMovieID:(NSUInteger)tmdbID options:(TMDBMovieFetchOptions)options;

+ (nullable NSURL *)searchURLWithMovieTitle:(nonnull NSString *)title year:(NSUInteger)year;

#pragma mark - Searching
/** @name Searching */

+ (void)moviesWithTitle:(nonnull NSString *)title completion:(nullable TMDBMoviesFetchCompletionBlock)completionBlock;

+ (void)moviesWithTitle:(nonnull NSString *)title year:(NSUInteger)year completion:(nullable TMDBMoviesFetchCompletionBlock)completionBlock;

@end
