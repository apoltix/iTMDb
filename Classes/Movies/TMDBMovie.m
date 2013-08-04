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
#import "TMDBRequestDelegate.h"

@interface TMDBMovie () <TMDBRequestDelegate>

- (NSArray *)arrayWithImages:(NSArray *)images ofType:(TMDBImageType)type;

@end

@implementation TMDBMovie {
@private
	TMDBRequest		*_request;

	NSInteger        _year;
	float			_rating;
	NSInteger		_revenue;
	NSURL			*_trailer;
	NSArray			*_studios;
	NSInteger		_popularity;
	NSUInteger		_version;
	NSDate			*_modified;

	BOOL			_isSearchingOnly;
	NSUInteger		_expectedYear;
}

@synthesize adult=_isAdult, translated=_isTranslated;

#pragma mark - Constructors

+ (instancetype)movieWithID:(NSUInteger)anID options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	return [[TMDBMovie alloc] initWithID:anID options:options context:context];
}

+ (instancetype)movieWithName:(NSString *)aName options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	return [[TMDBMovie alloc] initWithName:aName options:options context:context];
}

+ (instancetype)movieWithName:(NSString *)aName year:(NSUInteger)aYear options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	return [[TMDBMovie alloc] initWithName:aName year:aYear options:options context:context];
}

- (instancetype)initWithURL:(NSURL *)url options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	return (self = [self initWithURL:url options:options context:context userData:nil]);
}

- (instancetype)initWithURL:(NSURL *)url options:(TMDBMovieFetchOptions)options context:(TMDB *)context userData:(NSDictionary *)userData
{
	if (!(self = [self init]))
		return nil;

	_context = context;
	_options = options;
	_rawResults = nil;

	// Initialize the fetch request
	_request = [TMDBRequest requestWithURL:url delegate:self];

	return self;
}

- (instancetype)initWithID:(NSUInteger)anID options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	NSURL *url = [NSURL URLWithString:[TMDBAPIURLBase stringByAppendingFormat:@"%@/movie/%lu?api_key=%@&language=%@",
									   TMDBAPIVersion, anID, context.apiKey, context.language]];
	_isSearchingOnly = NO;
	return (self = [self initWithURL:url options:options context:context]);
}

- (instancetype)initWithName:(NSString *)name options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	NSString *aNameEscaped = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[TMDBAPIURLBase stringByAppendingFormat:@"%@/search/movie?api_key=%@&query=%@&language=%@",
									   TMDBAPIVersion, context.apiKey, aNameEscaped, context.language]];
	_isSearchingOnly = YES;
	return (self = [self initWithURL:url options:options context:context userData:@{@"title": name}]);
}

- (instancetype)initWithName:(NSString *)name year:(NSUInteger)year options:(TMDBMovieFetchOptions)options context:(TMDB *)context
{
	NSString *aNameEscaped = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[TMDBAPIURLBase stringByAppendingFormat:@"%@/search/movie?api_key=%@&query=%@&language=%@",
									   TMDBAPIVersion, context.apiKey, aNameEscaped, context.language]];
	_isSearchingOnly = YES;
	_expectedYear = year;
	return (self = [self initWithURL:url options:options context:context userData:@{@"title": name, @"year": @(year)}]);
}

#pragma mark -

- (NSString *)description
{
	if (!self.title)
		return [NSString stringWithFormat:@"<%@ %p>", [self class], self, nil];

	if (!self.released)
		return [NSString stringWithFormat:@"<%@ %p: %@>", [self class], self, self.title, nil];

	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *weekdayComponents = [cal components:NSYearCalendarUnit fromDate:self.released];
	NSInteger year = [weekdayComponents year];

	return [NSString stringWithFormat:@"<%@ %p: %@ (%li)>", [self class], self, self.title, year, nil];
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
	_id = [(NSNumber *)d[@"id"] integerValue];
	_title = [d[@"title"] copy];

	if (d[@"overview"] && [d[@"overview"] isKindOfClass:[NSString class]])
		_overview = [d[@"overview"] copy];
	else
		_overview = nil;

	if (d[@"tagline"] && [d[@"tagline"] isKindOfClass:[NSString class]])
		_tagline  = [d[@"tagline"] copy];
	if (d[@"imdb_id"] && [d[@"imdb_id"] isKindOfClass:[NSString class]])
		_imdbID   = [d[@"imdb_id"] copy];

	// COMPLEX DATA

	// Original name
	if (d[@"original_title"])
		_originalTitle = [d[@"original_title"] copy];

	// Alternative name
//	if (d[@"alternative_name"])
//		_alternativeName = [d[@"alternative_name"] copy];

	// Keywords
	if (d[@"keywords"] && [d[@"keywords"] isKindOfClass:[NSArray class]])
	{
		//_keywords = [[NSArray alloc] initWithArray:[d objectForKey:@"keywords"] copyItems:YES];
		_keywords = [d[@"keywords"] copy];
	}

	// URL
	if (d[@"url"])
		_url = [NSURL URLWithString:d[@"url"]];

	// Popularity
	if (d[@"popularity"])
		_popularity = [d[@"popularity"] integerValue];

	// Votes
	if (d[@"votes"])
		_votes = [d[@"votes"] integerValue];

	// Rating
	if (d[@"rating"])
		_rating = [d[@"rating"] floatValue];

	// Certification
	if (d[@"certification"])
		_certification = [d[@"certification"] copy];

	// Translated
	if (d[@"translated"] && ![d[@"translated"] isKindOfClass:[NSNull class]])
		_isTranslated = [d[@"translated"] boolValue];

	// Adult
	if (d[@"adult"] && ![d[@"adult"] isKindOfClass:[NSNull class]])
		_isAdult = [d[@"adult"] boolValue];

	// Language
	if (d[@"language"])
		_language = [d[@"language"] copy];

	// Version
	if (d[@"version"])
		_version = [d[@"version"] integerValue];

	// Release date
	if (d[@"released"] && [d[@"released"] isKindOfClass:[NSString class]])
	{
		_released = [self dateFromString:(NSString *)d[@"released"]];
	}

	// Runtime
	if (!(d[@"runtime"] == nil || [d[@"runtime"] isKindOfClass:[NSNull class]]))
		_runtime  = [d[@"runtime"] unsignedIntegerValue];

	// Homepage
	if (d[@"homepage"] && [d[@"homepage"] isKindOfClass:[NSString class]])
		_homepage = [NSURL URLWithString:d[@"homepage"]];
	else
		_homepage = nil;

	// Posters
	_posters = nil;
	if (d[@"posters"])
		_posters = [self arrayWithImages:d[@"posters"] ofType:TMDBImageTypePoster];
	//NSLog(@"POSTERS %@", _posters);

	// Backdrops
	_backdrops = nil;
	if (d[@"backdrops"])
		_backdrops = [self arrayWithImages:d[@"backdrops"] ofType:TMDBImageTypeBackdrop];
	//NSLog(@"BACKDROPS %@", _backdrops);

	// Cast
	_cast = nil;
	if (d[@"cast"] && ![d isKindOfClass:[NSNull class]])
		_cast = [TMDBPerson personsWithMovie:self personsInfo:d[@"cast"]];

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

- (NSArray *)arrayWithImages:(NSArray *)theImages ofType:(TMDBImageType)aType
{
	NSMutableArray *imageObjects = [NSMutableArray arrayWithCapacity:0];

	TMDBImage *currentImage = nil;
	// outerImageDict: the TMDb API wraps each image in a wrapper dictionary (e.g. each backdrop has an "images" dictionary)
	for (NSDictionary *outerImageDict in theImages)
	{
		// innerImageDict: the image info (see outerImageDict)
		NSDictionary *innerImageDict = outerImageDict[@"image"];

		// Fetch the existing image (if any)
		BOOL allocatedNewObject = NO;
		if (currentImage && ![currentImage.id isEqualToString:innerImageDict[@"id"]])
		{
			// Warning: This hasn't actually been tested yet
			NSIndexSet *passed = [imageObjects indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
				TMDBImage *lookupImage = (TMDBImage *)obj;
				BOOL passed = [lookupImage.id isEqualToString:innerImageDict[@"id"]];
				if (passed) // we only need one object
					*(stop) = YES;
				return passed;
			}];

			if ([passed count] > 0 && imageObjects)
				currentImage = imageObjects[[passed firstIndex]];
			else
				currentImage = nil;
		}

		// use !currentBackdrop instead of an else, as an object recovery (fetch) may have been performed
		if (!currentImage)
		{
			currentImage = [[TMDBImage alloc] initWithId:innerImageDict[@"id"] ofType:aType];
			allocatedNewObject = YES;
		}

		TMDBImageSize imgSize = -1;
		NSString *imgSizeString = innerImageDict[@"size"];
		if ([imgSizeString isEqualToString:@"original"])
			imgSize = TMDBImageSizeOriginal;
		else if ([imgSizeString isEqualToString:@"mid"])
			imgSize = TMDBImageSizeMid;
		else if ([imgSizeString isEqualToString:@"cover"])
			imgSize = TMDBImageSizeCover;
		else if ([imgSizeString isEqualToString:@"thumb"])
			imgSize = TMDBImageSizeThumb;

		[currentImage setURL:[NSURL URLWithString:innerImageDict[@"url"]] forSize:imgSize];

		// Add object if it doesn't already exist
		if (allocatedNewObject)
			[imageObjects addObject:currentImage];
	}
	return imageObjects;
}

@end