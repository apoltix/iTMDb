//
//  TMDB.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import "TMDB.h"

@implementation TMDB

@dynamic apiKey;
@synthesize delegate=_delegate, language=_language, token;

- (id)initWithAPIKey:(NSString *)apiKey delegate:(id <TMDBDelegate>)delegate
{
	self.delegate = delegate;
	self.apiKey = apiKey;
	token = nil;
	_language = @"en";

	return self;
}

#pragma mark -
#pragma mark Notifications
- (void)movieDidFinishLoading:(TMDBMovie *)movie
{
	//printf("Movie did finish loading: %s\n", [movie.title UTF8String]);

	if (_delegate)
		[_delegate tmdb:self didFinishLoadingMovie:movie];
}

- (void)movieDidFailLoading:(TMDBMovie *)movie error:(NSError *)error
{
	if (_delegate)
		[_delegate tmdb:self didFailLoadingMovie:movie error:error];
}

#pragma mark -
#pragma mark Shortcuts
- (TMDBMovie *)movieWithID:(NSInteger)anID
{
	return [TMDBMovie movieWithID:anID context:self];
}

- (TMDBMovie *)movieWithName:(NSString *)aName
{
	return [TMDBMovie movieWithName:aName context:self];
}

#pragma mark -
#pragma mark Getters and setters
- (NSString *)apiKey
{
	return _apiKey;
}

- (void)setApiKey:(NSString *)newKey
{
	// TODO: Invalidate active token
	_apiKey = [newKey copy];
}

@end