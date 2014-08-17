//
//  DMAppDelegate.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 09/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DMAppDelegate.h"
#import "DetailViewController.h"
#import "TMDBMovie+DMBlocks.h"

@interface DMAppDelegate () <TMDBDelegate>

@end

@implementation DMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.tmdb = [[TMDB alloc] initWithAPIKey:nil delegate:self language:nil];
	return YES;
}

#pragma mark - TMDBDelegate

- (void)tmdb:(TMDB *)context didFinishLoadingMovie:(TMDBMovie *)movie {
	if (movie.didFinishLoadingBlock != nil) {
		movie.didFinishLoadingBlock(nil);
	}
}

- (void)tmdb:(TMDB *)context didFailLoadingMovie:(TMDBMovie *)movie error:(NSError *)error {
	if (movie.didFinishLoadingBlock != nil) {
		movie.didFinishLoadingBlock(error);
	}
}

@end
