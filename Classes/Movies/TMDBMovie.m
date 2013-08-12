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
#import "TMDBRequest.h"

@interface TMDBMovie () <TMDBRequestDelegate>

@end

@implementation TMDBMovie {
@private
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

- (instancetype)initWithURL:(NSURL *)url options:(TMDBMovieFetchOptions)options context:(TMDB *)context userData:(NSDictionary *)userData
{
	if (!(self = [self init]))
		return nil;

	_context = context;
	_options = options;
	_rawResults = nil;
	_userData = userData;

	[self populateWithDataFromURL:url];

	return self;
}

- (instancetype)initWithID:(NSUInteger)anID options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	NSURL *url = [TMDBMovie fetchURLWithMovieID:anID options:options context:context];
	_isSearchingOnly = NO;
	return (self = [self initWithURL:url options:options context:context userData:nil]);
}

- (instancetype)initWithName:(NSString *)name options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	NSURL *url = [TMDBMovie fetchURLWithMovieTitle:name options:options context:context];
	_isSearchingOnly = YES;
	return (self = [self initWithURL:url options:options context:context userData:@{@"title": name}]);
}

- (instancetype)initWithName:(NSString *)name year:(NSUInteger)year options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	NSURL *url = [TMDBMovie fetchURLWithMovieTitle:name options:options context:context];
	_isSearchingOnly = YES;
	_expectedYear = year;
	return (self = [self initWithURL:url options:options context:context userData:@{@"title": name, @"year": @(year)}]);
}

#pragma mark - Data Fetching and Population

- (void)refetchData
{
	TMDBMovieFetchOptions options = TMDBMovieFetchOptionBasic;

	if (_id != 0)
		[self populateWithDataFromURL:[TMDBMovie fetchURLWithMovieID:_id options:options context:_context]];
	else if (_title != nil)
		[self populateWithDataFromURL:[TMDBMovie fetchURLWithMovieTitle:_title options:options context:_context]];
}

- (void)populateWithDataFromURL:(NSURL *)url
{
	// Initialize the fetch request
	_request = [TMDBRequest requestWithURL:url delegate:self];
}

#pragma mark - Fetch URLs

+ (NSString *)appendToResponseStringFromFetchOptions:(TMDBMovieFetchOptions)options
{
	if (options == 0 || options == TMDBMovieFetchOptionBasic)
		return @"";

	NSMutableString *s = [NSMutableString stringWithString:@"&append_to_response="];

	if ((options & TMDBMovieFetchOptionCasts) == TMDBMovieFetchOptionCasts)
		[s appendString:@"casts,"];

	if ((options & TMDBMovieFetchOptionKeywords) == TMDBMovieFetchOptionKeywords)
		[s appendString:@"keywords,"];

	if ((options & TMDBMovieFetchOptionImages) == TMDBMovieFetchOptionImages)
		[s appendString:@"images"];

	return [NSString stringWithString:s];
}

+ (NSURL *)fetchURLWithMovieID:(NSUInteger)anID options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	NSURL *url = [NSURL URLWithString:[TMDBAPIURLBase stringByAppendingFormat:@"%@/movie/%lu?api_key=%@&language=%@%@",
									   TMDBAPIVersion, anID, context.apiKey, context.language, [self appendToResponseStringFromFetchOptions:options]]];
	return url;
}

+ (NSURL *)fetchURLWithMovieTitle:(NSString *)name options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	NSString *aNameEscaped = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[TMDBAPIURLBase stringByAppendingFormat:@"%@/search/movie?api_key=%@&query=%@&language=%@%@",
									   TMDBAPIVersion, context.apiKey, aNameEscaped, context.language, [self appendToResponseStringFromFetchOptions:options]]];

	return url;
}

#pragma mark -

- (NSString *)description
{
	if (self.title == nil)
		return [NSString stringWithFormat:@"<%@ %p>", NSStringFromClass(self.class), self];

	if (self.released == nil)
		return [NSString stringWithFormat:@"<%@ %p: \"%@\">", NSStringFromClass(self.class), self, self.title];

	return [NSString stringWithFormat:@"<%@ %p: \"%@\" (%li)>", NSStringFromClass(self.class), self, self.title, self.year];
}

#pragma mark -

- (NSUInteger)year
{
	if (_year > 0)
		return _year;

	_year = [self yearFromDate:self.released];

	return _year;
}

- (void)setReleased:(NSDate *)released
{
	_released = released;

	[self willChangeValueForKey:@"year"];
	_year = 0; // invalidate cached value first
	_year = [self year];
	[self didChangeValueForKey:@"year"];
}

#pragma mark - TMDBRequestDelegate

- (void)request:(TMDBRequest *)request didFinishLoading:(NSError *)error
{
	if (error)
	{
		//NSLog(@"iTMDb: TMDBMovie request failed: %@", [error description]);
		if (_context)
		{
			NSDictionary *userInfo = @{
				TMDBMovieUserInfoKey: self,
				TMDBErrorUserInfoKey: error
			};
			[[NSNotificationCenter defaultCenter] postNotificationName:TMDBDidFailLoadingMovieNotification object:_context userInfo:userInfo];
		}
		return;
	}

	_rawResults = _isSearchingOnly ? (NSArray *)((NSDictionary *)[request parsedData])[@"results"] : (NSDictionary *)[request parsedData];

	if (!_rawResults || (_isSearchingOnly ? ![_rawResults count] > 0 || ![_rawResults[0] isKindOfClass:[NSDictionary class]] : NO))
	{
		//NSLog(@"iTMDb: Returned data is NOT a dictionary!\n%@", _rawResults);
		if (_context)
		{
			NSDictionary *errorDict = @{
				NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The data source (themoviedb) returned invalid data: %@", _rawResults]
			};

			NSError *failError = [NSError errorWithDomain:TMDBErrorDomain
													 code:TMDBErrorCodeReceivedInvalidData
												 userInfo:errorDict];
			NSDictionary *userInfo = @{
				TMDBMovieUserInfoKey: self,
				TMDBErrorUserInfoKey: failError
			};
			[[NSNotificationCenter defaultCenter] postNotificationName:TMDBDidFailLoadingMovieNotification object:_context userInfo:userInfo];
		}
		return;
	}

	NSDictionary *d = nil;

	// If there are multiple results, and the user specified an expected year
	// of release iterate over the search results and find the one matching
	// said year, if any.
	if (_isSearchingOnly && _expectedYear != 0)
	{
		for (NSDictionary *result in (NSArray *)_rawResults)
		{
			NSDate *releaseDate = [self dateFromString:(NSString *)result[@"release_date"]];
			NSUInteger releaseYear = [self yearFromDate:releaseDate];

			if (releaseYear == _expectedYear)
			{
				d = result;
				break;
			}
		}
	}

	if (d == nil)
		d = _isSearchingOnly ? ((NSArray *)_rawResults)[0] : _rawResults;

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
	_languagesSpoken = [TMDBLanguage languagesFromArrayOfDictionaries:TMDB_NSArrayOrNil(d[@"spoken_languages"]) context:_context];

	// Release date
	NSString *released = TMDB_NSStringOrNil(d[@"release_date"]);
	if (released != nil)
		_released = [self dateFromString:released];

	// Runtime
	_runtime = [TMDB_NSNumberOrNil(d[@"runtime"]) unsignedIntegerValue];

	// Homepage
	_homepage = TMDB_NSURLOrNilFromStringOrNil(d[@"homepage"]);

	// Images
	NSDictionary *images = TMDB_NSDictionaryOrNil(d[@"images"]);

	// Posters
	if (images != nil && images[@"posters"] != nil)
		_posters = [TMDBImage imageArrayWithRawImageDictionaries:images[@"posters"] ofType:TMDBImageTypePoster context:_context];
	else
		_posters = nil;

	// Backdrops
	if (images != nil && images[@"backdrops"] != nil)
		_backdrops = [TMDBImage imageArrayWithRawImageDictionaries:images[@"backdrops"] ofType:TMDBImageTypeBackdrop context:_context];
	else
		_backdrops = nil;
	NSLog(@"BACKDROPS %@", _backdrops);

	// Cast and Crew
	_cast = nil;
	if (d[@"casts"] && ![d isKindOfClass:[NSNull class]])
		_cast = [TMDBPerson personsWithMovie:self personsInfo:d[@"casts"]];

	if (_isSearchingOnly)
	{
		_isSearchingOnly = NO;
		if ([self initWithID:_id options:_options context:_context])
			; // NOOP to suppress compiler warning, probably not a good idea
		return;
	}

	// Notify the context that the movie info has been loaded
	if (_context)
	{
		NSDictionary *userInfo = @{
			TMDBMovieUserInfoKey: self
		};
		[[NSNotificationCenter defaultCenter] postNotificationName:TMDBDidFinishLoadingMovieNotification object:_context userInfo:userInfo];
	}
}

#pragma mark - Helper methods

- (NSUInteger)yearFromDate:(NSDate *)date
{
	static NSDateFormatter *df; // NSDateFormatters are expensive to create
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"YYYY"];
	});
	return [[df stringFromDate:date] integerValue];
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

@implementation TMDBMovie (DeprecatedMethods)

+ (instancetype)movieWithID:(NSUInteger)anID options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	return [[self alloc] initWithID:anID options:options context:context];
}

+ (instancetype)movieWithName:(NSString *)name options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	return [[self alloc] initWithName:name options:options context:context];
}

+ (instancetype)movieWithName:(NSString *)name year:(NSUInteger)year options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	return [[self alloc] initWithName:name year:year options:options context:context];
}

@end