//
//  DMAppDelegate.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 09/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DMAppDelegate.h"
#import "DetailViewController.h"

@interface DMAppDelegate ()

@end

@implementation DMAppDelegate

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{
		@"language": @"en"
	}];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.tmdb = [[TMDB alloc] initWithAPIKey:self.apiKey delegate:nil language:self.language];
	return YES;
}

#pragma mark -

- (NSString *)apiKey
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"apiKey"];
}

- (NSString *)language
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"language"];
}

@end
