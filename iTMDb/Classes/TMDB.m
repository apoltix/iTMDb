//
//  TMDB.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright (c) 2010 Devify. All rights reserved.
//

#import "TMDB.h"

NSString * const TMDBAPIURLBase = @"http://api.themoviedb.org/";
NSString * const TMDBAPIVersion = @"3";

@implementation TMDB

+ (instancetype)sharedInstance {
	static TMDB *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (instancetype)init {
	if (!(self = [super init]))
		return nil;

	_configuration = [[TMDBConfiguration alloc] init];

	return self;
}

#pragma mark - Getters and setters

- (void)setLanguage:(NSString *)language {
	if (language == nil || language.length == 0) {
		_language = @"en";
	}
	else {
		_language = [language copy];
	}
}

@end