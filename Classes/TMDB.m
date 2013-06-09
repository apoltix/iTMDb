//
//  TMDB.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import "TMDB.h"

@implementation TMDB

- (id)initWithAPIKey:(NSString *)anApiKey delegate:(id<TMDBDelegate>)aDelegate language:(NSString *)aLanguage
{
	if (!(self = [super init]))
		return nil;

	_delegate = aDelegate;
	_apiKey = [anApiKey copy];

	if (!aLanguage || [aLanguage length] == 0)
		_language = @"en";
	else
		_language = [aLanguage copy];

	return self;
}

#pragma mark - Notifications

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

#pragma mark - Shortcuts

- (TMDBMovie *)movieWithID:(NSInteger)anID
{
	return [TMDBMovie movieWithID:anID options:TMDBMovieFetchOptionBasic context:self];
}

- (TMDBMovie *)movieWithName:(NSString *)name
{
	return [TMDBMovie movieWithName:name options:TMDBMovieFetchOptionBasic context:self];
}

#pragma mark - Getters and setters

- (void)setApiKey:(NSString *)newKey
{
	// TODO: Invalidate active token
	_apiKey = [newKey copy];
}

@end