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
@synthesize delegate=_delegate, language=_language, token=_token;

- (id)initWithAPIKey:(NSString *)anApiKey delegate:(id<TMDBDelegate>)aDelegate language:(NSString *)aLanguage
{
	_delegate = aDelegate;
	_apiKey = [anApiKey copy];
	_token = nil;
	if (!aLanguage || [aLanguage length] == 0)
		_language = @"en";
	else
		_language = [aLanguage copy];

	return self;
}

#pragma mark -
#pragma mark Notifications
- (void)movieDidFinishLoading:(TMDBMovie *)aMovie
{
	if (_delegate)
		[_delegate tmdb:self didFinishLoadingMovie:aMovie];
}

- (void)movieDidFailLoading:(TMDBMovie *)aMovie error:(NSError *)error
{
	if (_delegate)
		[_delegate tmdb:self didFailLoadingMovie:aMovie error:error];
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

#pragma mark -

@end