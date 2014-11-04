//
//  TMDBMovie.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright (c) 2010 Devify. All rights reserved.
//

#import "TMDB.h"
#import "TMDBMovie.h"
#import "TMDBMovieSearch.h"
#import "TMDBImage.h"
#import "TMDBPerson.h"
#import "TMDBRequest.h"
#import "TMDBLanguage.h"

@implementation TMDBMovie {
@private
	NSInteger        _year;
	float			_rating;
	NSInteger		_revenue;
	NSURL			*_trailer;
	NSArray			*_studios;
	double			_popularity; // TODO: Make public property
	NSDate			*_modified;
}

@synthesize adult=_isAdult;

#pragma mark - Initializers

- (instancetype)initWithID:(NSUInteger)tmdbID {
	if (!(self = [super init])) {
		return nil;
	}

	_tmdbID = tmdbID;

	return self;
}

#pragma mark - Data Fetching

- (void)load:(TMDBMovieFetchOptions)options completion:(TMDBMovieFetchCompletionBlock)completionBlock {
	NSURL *url = [TMDBMovieSearch fetchURLWithMovieID:_tmdbID options:options];

	if (url == nil) {
		if (completionBlock != nil) {
			NSError *error = [NSError errorWithDomain:TMDBErrorDomain
												 code:TMDBErrorCodeInvalidURL
											 userInfo:nil];
			completionBlock(error);
		}
		return;
	}

	[TMDBRequest requestWithURL:url completionBlock:^(id parsedData, NSError *error) {
		if (error != nil) {
			if (completionBlock != nil) {
				completionBlock(error);
			}
			return;
		}

		[self populate:parsedData];

		if (completionBlock != nil) {
			completionBlock(error);
		}
	}];
}

#pragma mark -

- (NSString *)description {
	if (self.title == nil || self.title.length == 0) {
		return [NSString stringWithFormat:@"<%@ %p>", NSStringFromClass(self.class), self];
	}

	if (self.released == nil) {
		return [NSString stringWithFormat:@"<%@ %p: \"%@\">", NSStringFromClass(self.class), self, self.title];
	}

	return [NSString stringWithFormat:@"<%@ %p: \"%@\" (%zd)>", NSStringFromClass(self.class), self, self.title, self.year];
}

#pragma mark - Getters and Setters

// Private
- (void)calculateYear {
	_year = [TMDBMovie yearFromDate:self.released];
}

- (NSUInteger)year {
	if (_year > 0) {
		return _year;
	}

	[self calculateYear];

	return _year;
}

- (void)setReleased:(NSDate *)released {
	_released = released;

	[self willChangeValueForKey:@"year"];
	[self calculateYear];
	[self didChangeValueForKey:@"year"];
}

#pragma mark - Data Population

- (void)populate:(NSDictionary *)d {
	// SIMPLE DATA
	_tmdbID   = [TMDB_NSNumberOrNil((NSNumber *)d[@"id"]) integerValue];
	_title    = TMDB_NSStringOrNil(d[@"title"]);
	_overview = TMDB_NSStringOrNil(d[@"overview"]);
	_tagline  = TMDB_NSStringOrNil(d[@"tagline"]);
	_imdbID   = TMDB_NSStringOrNil(d[@"imdb_id"]);

	// COMPLEX DATA

	// Original name
	_originalTitle = TMDB_NSStringOrNil(d[@"original_title"]);

	// Alternative name
//	if (d[@"alternative_name"])
//		_alternativeName = [d[@"alternative_name"] copy];

	// Keywords
	_keywords = [TMDB_NSArrayOrNil(d[@"keywords"]) copy];

	// URL
	_url = TMDB_NSURLOrNilFromStringOrNil(d[@"url"]);

	// Popularity
	_popularity = [TMDB_NSNumberOrNil(d[@"popularity"]) doubleValue];

	// Votes
	_votes = [TMDB_NSNumberOrNil(d[@"votes"]) integerValue];

	// Rating
	_rating = [TMDB_NSNumberOrNil(d[@"rating"]) floatValue];

	// Adult
	_isAdult = [TMDB_NSNumberOrNil(d[@"adult"]) boolValue];

	// Spoken Languages
	_languagesSpoken = [TMDBLanguage languagesFromArrayOfDictionaries:TMDB_NSArrayOrNil(d[@"spoken_languages"])];

	// Release date
	NSString *released = TMDB_NSStringOrNil(d[@"release_date"]);
	if (released != nil) {
		_released = [TMDBMovie dateFromString:released];
	}

	// Runtime
	_runtime = [TMDB_NSNumberOrNil(d[@"runtime"]) unsignedIntegerValue];

	// Homepage
	_homepage = TMDB_NSURLOrNilFromStringOrNil(d[@"homepage"]);

	// Images
	NSDictionary *images = TMDB_NSDictionaryOrNil(d[@"images"]);

	// Posters
	if (images != nil && images[@"posters"] != nil) {
		_posters = [TMDBImage imageArrayWithRawImageDictionaries:images[@"posters"] ofType:TMDBImageTypePoster];
	}
	else {
		_posters = nil;
	}

	// Backdrops
	if (images != nil && images[@"backdrops"] != nil) {
		_backdrops = [TMDBImage imageArrayWithRawImageDictionaries:images[@"backdrops"] ofType:TMDBImageTypeBackdrop];
	}
	else {
		_backdrops = nil;
	}

	// Cast and Crew
	NSDictionary *rawCasts = TMDB_NSDictionaryOrNil(d[@"casts"]);
	if (rawCasts != nil && rawCasts.count > 0) {
		NSMutableArray *casts = [NSMutableArray array];
		for (NSString *key in rawCasts) {
			NSArray *castsPart = [TMDBPerson personsWithMovie:self personsInfo:rawCasts[key]];
			if (castsPart.count > 0) {
				[casts addObjectsFromArray:castsPart];
			}
		}
		_cast = [casts copy];
	}
	else {
		_cast = nil;
	}

	// Keywords
	NSArray *rawKeywords = TMDB_NSArrayOrNil(TMDB_NSDictionaryOrNil(d[@"keywords"])[@"keywords"]);
	if (rawKeywords != nil && rawKeywords.count > 0) {
		NSMutableArray *keywords = [NSMutableArray arrayWithCapacity:rawKeywords.count];
		for (NSDictionary *keyword in rawKeywords) {
			[keywords addObject:keyword[@"name"]];
		}
		_keywords = [keywords copy];
	}
	else {
		_keywords = nil;
	}
}

#pragma mark - Helper methods

+ (NSUInteger)yearFromDate:(NSDate *)date {
	static NSDateFormatter *df; // NSDateFormatters are expensive to create
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"YYYY"];
	});
	return [df stringFromDate:date].integerValue;
}

+ (NSDate *)dateFromString:(NSString *)dateString {
	static NSDateFormatter *releasedFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		releasedFormatter = [[NSDateFormatter alloc] init];
		[releasedFormatter setDateFormat:@"yyyy-MM-dd"];
	});
	return [releasedFormatter dateFromString:dateString];
}

@end
