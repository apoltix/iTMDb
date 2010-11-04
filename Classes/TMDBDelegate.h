//
//  TMDBDelegate.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TMDB;
@class TMDBMovie;

@protocol TMDBDelegate

@required

- (void)tmdb:(TMDB *)context didFinishLoadingMovie:(TMDBMovie *)movie;
- (void)tmdb:(TMDB *)context didFailLoadingMovie:(TMDBMovie *)movie error:(NSError *)error;

@end