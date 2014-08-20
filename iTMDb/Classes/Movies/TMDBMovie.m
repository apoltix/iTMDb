//
//  TMDBMovie.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import "TMDB.h"
#import "TMDBMovie.h"
#import "TMDBImage.h"
#import "TMDBPerson.h"
#import "TMDBRequest.h"
#import "TMDBLanguage.h"

@implementation TMDBMovie {
@private
	NSURL			*_fetchURL;
	TMDBRequest		*_request;

	NSInteger        _year;
	float			_rating;
	NSInteger		_revenue;
	NSURL			*_trailer;
	NSArray			*_studios;
	double			_popularity; // TODO: Make public property
	NSDate			*_modified;

	BOOL			_isSearchingOnly;
	NSUInteger		_expectedYear;
}

@synthesize adult=_isAdult;

#pragma mark - Constructors

// Private
- (instancetype)initWithURL:(NSURL *)url options:(TMDBMovieFetchOptions)options userData:(NSDictionary *)userData {
	if (!(self = [super init])) {
		return nil;
	}

	_fetchURL = url;
	_options = options;
	_rawResults = nil;
	_userData = [userData copy];

	return self;
}

- (instancetype)initWithID:(NSUInteger)anID options:(TMDBMovieFetchOptions)options {
	NSURL *url = [TMDBMovie fetchURLWithMovieID:anID options:options];
	_isSearchingOnly = NO;
	return (self = [self initWithURL:url options:options userData:nil]);
}

- (instancetype)initWithName:(NSString *)name options:(TMDBMovieFetchOptions)options {
	NSURL *url = [TMDBMovie fetchURLWithMovieTitle:name options:options];
	_isSearchingOnly = YES;
	return (self = [self initWithURL:url options:options userData:@{@"title": name}]);
}

- (instancetype)initWithName:(NSString *)name year:(NSUInteger)year options:(TMDBMovieFetchOptions)options {
	NSURL *url = [TMDBMovie fetchURLWithMovieTitle:name options:options];
	_isSearchingOnly = YES;
	_expectedYear = year;
	return (self = [self initWithURL:url options:options userData:@{@"title": name, @"year": @(year)}]);
}

#pragma mark - Data Fetching

- (void)load:(TMDBMovieFetchCompletionBlock)completionBlock {
	NSURL *url = _fetchURL;

	if (_id != 0) {
		url = [TMDBMovie fetchURLWithMovieID:_id options:_options];
	}
	else if (_title != nil) {
		url = [TMDBMovie fetchURLWithMovieTitle:_title options:_options];
	}

	if (url != nil) {
		[TMDBRequest requestWithURL:url completionBlock:^(id parsedData, NSError *error) {
			[self parseData:parsedData error:error completion:completionBlock];
		}];
	}
}

#pragma mark - Fetch URLs

+ (NSString *)appendToResponseStringFromFetchOptions:(TMDBMovieFetchOptions)options {
	if (options == 0 || options == TMDBMovieFetchOptionBasic) {
		return @"";
	}

	NSMutableArray *optionsArray = [NSMutableArray array];

	if ((options & TMDBMovieFetchOptionCasts) == TMDBMovieFetchOptionCasts) {
		[optionsArray addObject:@"casts"];
	}

	if ((options & TMDBMovieFetchOptionKeywords) == TMDBMovieFetchOptionKeywords) {
		[optionsArray addObject:@"keywords"];
	}

	if ((options & TMDBMovieFetchOptionImages) == TMDBMovieFetchOptionImages) {
		[optionsArray addObject:@"images"];
	}

	return [NSString stringWithFormat:@"&append_to_response=%@", [optionsArray componentsJoinedByString:@","]];
}

+ (NSURL *)fetchURLWithMovieID:(NSUInteger)anID options:(TMDBMovieFetchOptions)options {
	TMDB *context = [TMDB sharedInstance];
	NSURL *url = [NSURL URLWithString:[TMDBAPIURLBase stringByAppendingFormat:@"%@/movie/%tu?api_key=%@&language=%@%@",
									   TMDBAPIVersion, anID, context.apiKey, context.language, [self appendToResponseStringFromFetchOptions:options]]];
	return url;
}

+ (NSURL *)fetchURLWithMovieTitle:(NSString *)name options:(TMDBMovieFetchOptions)options {
	TMDB *context = [TMDB sharedInstance];
	NSString *aNameEscaped = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[TMDBAPIURLBase stringByAppendingFormat:@"%@/search/movie?api_key=%@&query=%@&language=%@%@",
									   TMDBAPIVersion, context.apiKey, aNameEscaped, context.language, [self appendToResponseStringFromFetchOptions:options]]];

	return url;
}

#pragma mark -

- (NSString *)description {
	if (self.title == nil) {
		return [NSString stringWithFormat:@"<%@ %p>", NSStringFromClass(self.class), self];
	}

	if (self.released == nil) {
		return [NSString stringWithFormat:@"<%@ %p: \"%@\">", NSStringFromClass(self.class), self, self.title];
	}

	return [NSString stringWithFormat:@"<%@ %p: \"%@\" (%zd)>", NSStringFromClass(self.class), self, self.title, self.year];
}

#pragma mark -

// Private
- (void)calculateYear {
	_year = [self yearFromDate:self.released];
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

#pragma mark -

- (void)parseData:(id)parsedData error:(NSError *)error completion:(TMDBMovieFetchCompletionBlock)completionBlock {
	TMDB *context = [TMDB sharedInstance];

	if (error != nil) {
		if (completionBlock != nil) {
			completionBlock(error);
		}
		return;
	}

	if (_isSearchingOnly) {
		_rawResults = (NSArray *)((NSDictionary *)parsedData)[@"results"];
	}
	else {
		_rawResults = (NSDictionary *)parsedData;
	}

	if (_rawResults == nil || (_isSearchingOnly ? ![_rawResults count] > 0 || ![_rawResults[0] isKindOfClass:[NSDictionary class]] : NO)) {
		//NSLog(@"iTMDb: Returned data is NOT a dictionary!\n%@", _rawResults);
		if (context != nil) {
			NSDictionary *errorDict = @{
				NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The data source (themoviedb) returned invalid data: %@", _rawResults]
			};

			NSError *failError = [NSError errorWithDomain:TMDBErrorDomain
													 code:TMDBErrorCodeReceivedInvalidData
												 userInfo:errorDict];

			if (completionBlock != nil) {
				completionBlock(failError);
			}
		}
		return;
	}

	NSDictionary *d = nil;

	// If there are multiple results, and the user specified an expected year
	// of release iterate over the search results and find the one matching
	// said year, if any.
	if (_isSearchingOnly && _expectedYear != 0) {
		for (NSDictionary *result in (NSArray *)_rawResults) {
			NSDate *releaseDate = [self dateFromString:(NSString *)result[@"release_date"]];
			NSUInteger releaseYear = [self yearFromDate:releaseDate];

			if (releaseYear == _expectedYear) {
				d = result;
				break;
			}
		}
	}

	if (d == nil) {
		if (_isSearchingOnly) {
			d = ((NSArray *)_rawResults)[0];
		}
		else {
			d = _rawResults;
		}
	}

	// SIMPLE DATA
	_id       = [TMDB_NSNumberOrNil((NSNumber *)d[@"id"]) integerValue];
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
	_languagesSpoken = [TMDBLanguage languagesFromArrayOfDictionaries:TMDB_NSArrayOrNil(d[@"spoken_languages"]) context:context];

	// Release date
	NSString *released = TMDB_NSStringOrNil(d[@"release_date"]);
	if (released != nil) {
		_released = [self dateFromString:released];
	}

	// Runtime
	_runtime = [TMDB_NSNumberOrNil(d[@"runtime"]) unsignedIntegerValue];

	// Homepage
	_homepage = TMDB_NSURLOrNilFromStringOrNil(d[@"homepage"]);

	// Images
	NSDictionary *images = TMDB_NSDictionaryOrNil(d[@"images"]);

	// Posters
	if (images != nil && images[@"posters"] != nil) {
		_posters = [TMDBImage imageArrayWithRawImageDictionaries:images[@"posters"] ofType:TMDBImageTypePoster context:context];
	}
	else {
		_posters = nil;
	}

	// Backdrops
	if (images != nil && images[@"backdrops"] != nil) {
		_backdrops = [TMDBImage imageArrayWithRawImageDictionaries:images[@"backdrops"] ofType:TMDBImageTypeBackdrop context:context];
	}
	else {
		_backdrops = nil;
	}

	// Cast and Crew
	_cast = nil;
	if (TMDB_NSDictionaryOrNil(d[@"casts"]) != nil) {
		NSDictionary *rawCasts = (NSDictionary *)d[@"casts"];
		NSMutableArray *casts = [NSMutableArray array];
		for (NSString *key in rawCasts) {
			NSArray *castsPart = [TMDBPerson personsWithMovie:self personsInfo:rawCasts[key]];
			if ([castsPart count] > 0)
				[casts addObjectsFromArray:castsPart];
		}
		_cast = [casts copy];
	}

	// Keywords
	NSArray *rawKeywords = TMDB_NSArrayOrNil(TMDB_NSDictionaryOrNil(d[@"keywords"])[@"keywords"]);
	if (rawKeywords.count > 0) {
		NSMutableArray *keywords = [NSMutableArray arrayWithCapacity:rawKeywords.count];
		for (NSDictionary *keyword in rawKeywords) {
			[keywords addObject:keyword[@"name"]];
		}
		_keywords = [keywords copy];
	}
	else {
		_keywords = nil;
	}

	if (_isSearchingOnly) {
		_isSearchingOnly = NO;
		[self load:completionBlock];
		return;
	}

	if (completionBlock != nil) {
		completionBlock(nil);
	}
}

#pragma mark - Helper methods

- (NSUInteger)yearFromDate:(NSDate *)date {
	static NSDateFormatter *df; // NSDateFormatters are expensive to create
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"YYYY"];
	});
	return [df stringFromDate:date].integerValue;
}

- (NSDate *)dateFromString:(NSString *)dateString
{
	static NSDateFormatter *releasedFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		releasedFormatter = [[NSDateFormatter alloc] init];
		[releasedFormatter setDateFormat:@"yyyy-MM-dd"];
	});
	return [releasedFormatter dateFromString:dateString];
}

@end
