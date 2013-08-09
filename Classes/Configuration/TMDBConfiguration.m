//
//  TMDBConfiguration.m
//  iTMDb
//
//  Created by Christian Rasmussen on 09/08/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

#import "TMDBConfiguration.h"
#import "TMDB.h"
#import "TMDBRequest.h"

@interface TMDBConfiguration () <TMDBRequestDelegate>

@end

@implementation TMDBConfiguration

@synthesize loaded=_isLoaded;

- (id)initWithContext:(TMDB *)context
{
	if (!(self = [super init]))
		return nil;

	_context = context;

	NSString *configURLString = [NSString stringWithFormat:@"%@%@/configuration", TMDBAPIURLBase, TMDBAPIVersion];
	NSURL *configURL = [NSURL URLWithString:configURLString];
	if (![TMDBRequest requestWithURL:configURL delegate:self])
		TMDBLog(@"Could not create request for configuration.");

	return self;
}

#pragma mark - TMDBRequestDelegate

- (void)request:(TMDBRequest *)request didFinishLoading:(NSError *)error
{
	if (error != nil)
	{
		TMDBLog(@"Configuration fetch request failed with error: %@", error);
		return;
	}
}

@end