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

@synthesize id=_id, name=_name, character=_character, movie=_movie, job=_job, url=_url, order=_order, castID=_castID;

+ (NSArray *)personsWithMovie:(TMDBMovie *)movie personsInfo:(NSArray *)personsInfo
{
	NSMutableArray *persons = [[NSMutableArray arrayWithCapacity:[personsInfo count]] retain];

	for (NSDictionary *person in personsInfo)
		[persons addObject:[[TMDBPerson alloc] initWithMovie:movie personInfo:person]];

	return persons;
}

- (id)initWithMovie:(TMDBMovie *)aMovie personInfo:(NSDictionary *)personInfo
{
	if ((self = [super init]))
	{
		_movie = [aMovie retain];
		_id = [[personInfo objectForKey:@"id"] integerValue];
		_name = [[personInfo objectForKey:@"name"] copy];
		_character = [[personInfo objectForKey:@"character"] copy];
		_job = [[personInfo objectForKey:@"job"] copy];
		_url = [[NSURL URLWithString:[personInfo objectForKey:@"url"]] retain];
		_order = [[personInfo objectForKey:@"order"] integerValue];
		_castID = [[personInfo objectForKey:@"cast_id"] integerValue];
	}
	return self;
}

- (NSString *)description
{
	if (_movie      &&
		_character  && ![_character isKindOfClass:[NSNull class]] && [_character length] > 0 &&
		_name       && ![_name isKindOfClass:[NSNull class]]      && [_name length] > 0)
		return [NSString stringWithFormat:@"<%@: %@ as \"%@\" in %@>", [self class], _name, _character, _movie.title, nil];
	else if (_movie &&
			 _name  && ![_name isKindOfClass:[NSNull class]]      && [_name length] > 0      &&
			 _job   && ![_job isKindOfClass:[NSNull class]]       && [_job length] > 0)
		return [NSString stringWithFormat:@"<%@: %@ as %@ of %@>", [self class], _name, _job, _movie.title, nil];
	else if (_movie &&
			 _name  && ![_name isKindOfClass:[NSNull class]]      && [_name length] > 0)
		return [NSString stringWithFormat:@"<%@: %@ in %@>", [self class], _name, _movie.title, nil];
	else if (_name  && ![_name isKindOfClass:[NSNull class]]      && [_name length] > 0)
		return [NSString stringWithFormat:@"<%@: %@>", [self class], _name, nil];

	return [NSString stringWithFormat:@"<%@>", [self class]];
}

- (void)dealloc
{
	[_movie release];
	[_url release];

	[super dealloc];
}

@end