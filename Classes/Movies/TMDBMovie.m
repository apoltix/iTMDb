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

@interface TMDBMovie ()

- (id)initWithURL:(NSURL *)url context:(TMDB *)context;
- (id)initWithURL:(NSURL *)url context:(TMDB *)context userData:(NSDictionary *)userData;

- (NSArray *)arrayWithImages:(NSArray *)images ofType:(TMDBImageType)type;

@end

@implementation TMDBMovie

#pragma mark - Constructors

+ (TMDBMovie *)movieWithID:(NSInteger)anID context:(TMDB *)aContext
{
	return [[TMDBMovie alloc] initWithID:anID context:aContext];
}

+ (TMDBMovie *)movieWithName:(NSString *)aName context:(TMDB *)aContext
{
	return [[TMDBMovie alloc] initWithName:aName context:aContext];
}

- (id)initWithURL:(NSURL *)url context:(TMDB *)aContext
{
	return (self = [self initWithURL:url context:aContext userData:nil]);
}

- (id)initWithURL:(NSURL *)url context:(TMDB *)aContext userData:(NSDictionary *)userData
{
	if ((self = [self init]))
	{
		_context = aContext;

		_rawResults = nil;

		_id = 0;
		_userData = userData;
		_title = nil;
		_released = nil;
		_overview = nil;
		_runtime = 0;
		_tagline = nil;
		_homepage = nil;
		_imdbID = nil;
		_posters = nil;
		_backdrops = nil;
		_rating = 0;
		_revenue = 0;
		_trailer = nil;
		_studios = nil;
		_originalName = nil;
		_alternativeName = nil;
		_popularity = 0;
		_translated = NO;
		_adult = NO;
		_language = nil;
		_url = nil;
		_votes = 0;
		_certification = nil;
		_categories = nil;
		_keywords = nil;
		_languagesSpoken = nil;
		_countries = nil;
		_cast = nil;
		_version = 0;
		_modified = nil;
		
		// Initialize the fetch request
		_request = [TMDBRequest requestWithURL:url delegate:self];
	}

	return self;
}

- (id)initWithID:(NSInteger)anID context:(TMDB *)aContext
{
	NSURL *url = [NSURL URLWithString:[API_URL_BASE stringByAppendingFormat:@"%.1f/Movie.getInfo/%@/json/%@/%li",
									   API_VERSION, aContext.language, aContext.apiKey, anID]];
	isSearchingOnly = NO;
	return (self = [self initWithURL:url context:aContext]);
}

- (id)initWithName:(NSString *)aName context:(TMDB *)aContext
{
	NSString *aNameEscaped = [aName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[API_URL_BASE stringByAppendingFormat:@"%.1f/Movie.search/%@/json/%@/%@",
									   API_VERSION, aContext.language, aContext.apiKey, aNameEscaped]];
	isSearchingOnly = YES;
	return (self = [self initWithURL:url context:aContext userData:@{@"title": aName}]);
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

	static NSDateFormatter *df; // NSDateFormatters are expensive to create
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"YYYY"];
	});

	_year = [[df stringFromDate:self.released] integerValue];
	return _year;
}

- (void)setReleased:(NSDate *)released
{
	[self willChangeValueForKey:@"released"];
	[self willChangeValueForKey:@"year"];
	_released = released;
	_year = 0; // invalidate cached value
	[self didChangeValueForKey:@"released"];
	[self didChangeValueForKey:@"year"];
}

#pragma mark - TMDBRequestDelegate
- (void)request:(TMDBRequest *)request didFinishLoading:(NSError *)error
{
	if (error)
	{
		//NSLog(@"iTMDb: TMDBMovie request failed: %@", [error description]);
		if (_context)
			[_context movieDidFailLoading:self error:error];
		return;
	}

	_rawResults = [[NSArray alloc] initWithArray:(NSArray *)[request parsedData] copyItems:YES];

	if (!_rawResults || ![_rawResults count] > 0 || ![_rawResults[0] isKindOfClass:[NSDictionary class]])
	{
		//NSLog(@"iTMDb: Returned data is NOT a dictionary!\n%@", _rawResults);
		if (_context)
		{
			NSDictionary *errorDict = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The data source (themoviedb) returned invalid data: %@", _rawResults]};
			NSError *failError = [NSError errorWithDomain:@"Invalid data"
													 code:0
												 userInfo:errorDict];
			[_context movieDidFailLoading:self error:failError];
		}
		return;
	}

	NSDictionary *d = _rawResults[0];

	// SIMPLE DATA
	_id       = [(NSNumber *)d[@"id"] integerValue];
	_title    = [d[@"name"] copy];

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
	if (d[@"original_name"])
		_originalName = [d[@"original_name"] copy];

	// Alternative name
	if (d[@"alternative_name"])
		_alternativeName = [d[@"alternative_name"] copy];

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
		_translated = [d[@"translated"] boolValue];

	// Adult
	if (d[@"adult"] && ![d[@"adult"] isKindOfClass:[NSNull class]])
		_adult = [d[@"adult"] boolValue];

	// Language
	if (d[@"language"])
		_language = [d[@"language"] copy];

	// Version
	if (d[@"version"])
		_version = [d[@"version"] integerValue];

	// Release date
	if (d[@"released"] && [d[@"released"] isKindOfClass:[NSString class]])
	{
		static NSDateFormatter *releasedFormatter;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			releasedFormatter = [[NSDateFormatter alloc] init];
			[releasedFormatter setDateFormat:@"yyyy-MM-dd"];
		});
		_released = [releasedFormatter dateFromString:(NSString *)d[@"released"]];
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

	if (isSearchingOnly)
	{
		isSearchingOnly = NO;
		if ([self initWithID:_id context:_context])
			; // NOOP to suppress compiler warning, probably not a good idea
		return;
	}

	// Notify the context that the movie info has been loaded
	if (_context)
		[_context movieDidFinishLoading:self];
}

#pragma mark - Helper methods
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