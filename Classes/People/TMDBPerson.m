//
//  TMDBPerson.m
//  iTMDb
//
//  Created by Christian Rasmussen on 29/12/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import "TMDBPerson.h"
#import "TMDBMovie.h"
#import "TMDB.h"
#import "TMDBRequest.h"

@implementation TMDBPerson

+ (NSArray *)personsWithMovie:(TMDBMovie *)movie personsInfo:(NSArray *)d
{
	NSMutableArray *persons = [NSMutableArray arrayWithCapacity:[d count]];

	for (NSDictionary *person in d)
		[persons addObject:[[TMDBPerson alloc] initWithMovie:movie personInfo:person]];

	return [NSArray arrayWithArray:persons];
}

- (instancetype)initWithMovie:(TMDBMovie *)movie personInfo:(NSDictionary *)d
{
	if (!(self = [super init]))
		return nil;

	_movie = movie;
	_context = movie.context;

	if (d != nil)
	{
		_id = [TMDB_NSNumberOrNil(d[@"id"]) unsignedIntegerValue];
		_name = [TMDB_NSStringOrNil(d[@"name"]) copy];
		_character = [TMDB_NSStringOrNil(d[@"character"]) copy];
		_job = [TMDB_NSStringOrNil(d[@"job"]) copy];
		_url = TMDB_NSURLOrNilFromStringOrNil(d[@"url"]);
		_order = [TMDB_NSNumberOrNil(d[@"order"]) integerValue];
		_castID = [TMDB_NSNumberOrNil(d[@"cast_id"]) integerValue];
		_profileURL = TMDB_NSURLOrNilFromStringOrNil(d[@"profile"]);
	}

	return self;
}

- (NSString *)description
{
	if (_movie      &&
		_character  && ![_character isKindOfClass:[NSNull class]] && [_character length] > 0 &&
		_name       && ![_name isKindOfClass:[NSNull class]]      && [_name length] > 0)
		return [NSString stringWithFormat:@"<%@ %p: %@ as \"%@\" in \"%@\"%@>", [self class], self, _name, _character, _movie.title, _movie.year > 0 ? [NSString stringWithFormat:@" (%li)", _movie.year] : @"", nil];
	else if (_movie &&
			 _name  && ![_name isKindOfClass:[NSNull class]]      && [_name length] > 0      &&
			 _job   && ![_job isKindOfClass:[NSNull class]]       && [_job length] > 0)
		return [NSString stringWithFormat:@"<%@ %p: %@ as %@ of \"%@\"%@>", [self class], self, _name, _job, _movie.title, _movie.year > 0 ? [NSString stringWithFormat:@" (%li)", _movie.year] : @"", nil];
	else if (_movie &&
			 _name  && ![_name isKindOfClass:[NSNull class]]      && [_name length] > 0)
		return [NSString stringWithFormat:@"<%@ %p: %@ in \"%@\"%@>", [self class], self, _name, _movie.title, _movie.year > 0 ? [NSString stringWithFormat:@" (%li)", _movie.year] : @"", nil];
	else if (_name  && ![_name isKindOfClass:[NSNull class]]      && [_name length] > 0)
		return [NSString stringWithFormat:@"<%@ %p: %@>", [self class], self, _name, nil];

	return [NSString stringWithFormat:@"<%@ %p>", [self class], self];
}

@end