//
//  TMDBPerson.m
//  iTMDb
//
//  Created by Christian Rasmussen on 29/12/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import "TMDBPerson.h"
#import "TMDBMovie.h"

@implementation TMDBPerson

+ (NSArray *)personsWithMovie:(TMDBMovie *)movie personsInfo:(NSArray *)personsInfo
{
	NSMutableArray *persons = [NSMutableArray arrayWithCapacity:[personsInfo count]];

	for (NSDictionary *person in personsInfo)
		[persons addObject:[[TMDBPerson alloc] initWithMovie:movie personInfo:person]];

	return [NSArray arrayWithArray:persons];
}

- (id)initWithMovie:(TMDBMovie *)aMovie personInfo:(NSDictionary *)personInfo
{
	if ((self = [super init]))
	{
		_movie = aMovie;
		_id = [personInfo[@"id"] integerValue];
		_name = [personInfo[@"name"] copy];
		_character = [personInfo[@"character"] copy];
		_job = [personInfo[@"job"] copy];
		_url = [NSURL URLWithString:personInfo[@"url"]];
		_order = [personInfo[@"order"] integerValue];
		_castID = [personInfo[@"cast_id"] integerValue];
		_profileURL = [NSURL URLWithString:personInfo[@"profile"]];
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