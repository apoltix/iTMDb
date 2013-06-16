//
//  TMDB.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import "TMDB.h"

NSString * const TMDBAPIURLBase = @"http://api.themoviedb.org/";
NSString * const TMDBAPIVersion = @"3";

NSString * const TMDBDidFinishLoadingMovieNotification = @"TMDBDidFinishLoadingMovieNotification";
NSString * const TMDBDidFailLoadingMovieNotification = @"TMDBDidFailLoadingMovieNotification";

NSString * const TMDBMovieUserInfoKey = @"TMDBMovieUserInfoKey";
NSString * const TMDBErrorUserInfoKey = @"TMDBErrorUserInfoKey";

@implementation TMDB

- (instancetype)initWithAPIKey:(NSString *)apiKey delegate:(id<TMDBDelegate>)delegate language:(NSString *)language
{
	if (!(self = [super init]))
		return nil;

	self.delegate = delegate;
	self.apiKey = apiKey;
	self.language = language;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDidFinishLoading:) name:TMDBDidFinishLoadingMovieNotification object:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDidFailLoading:)   name:TMDBDidFailLoadingMovieNotification   object:self];

	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TMDBDidFinishLoadingMovieNotification object:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TMDBDidFailLoadingMovieNotification   object:self];
}

#pragma mark - Notifications

- (void)movieDidFinishLoading:(NSNotification *)n
{
	if (_delegate)
		[_delegate tmdb:self didFinishLoadingMovie:n.userInfo[TMDBMovieUserInfoKey]];
}

- (void)movieDidFailLoading:(NSNotification *)n
{
	if (_delegate)
		[_delegate tmdb:self didFailLoadingMovie:n.userInfo[TMDBMovieUserInfoKey] error:n.userInfo[TMDBErrorUserInfoKey]];
}

#pragma mark - Getters and setters

- (void)setLanguage:(NSString *)language
{
	if (!language || [language length] == 0)
		_language = @"en";
	else
		_language = [language copy];
}

@end