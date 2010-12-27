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

@interface TMDBMovie ()

- (id)initWithURL:(NSURL *)url context:(TMDB *)context;
- (id)initWithURL:(NSURL *)url context:(TMDB *)context userData:(NSDictionary *)userData;

- (NSArray *)arrayWithImages:(NSArray *)images ofType:(TMDBImageType)type;

@end

@implementation TMDBMovie

@synthesize context=_context,
            rawResults=_rawResults,
            id=_id,
			userData=_userData,
            title=_title,
            released=_released,
            overview=_overview,
            runtime=_runtime,
            tagline=_tagline,
            homepage=_homepage,
            imdbID=_imdbID,
            posters=_posters,
            backdrops=_backdrops;

#pragma mark -
#pragma mark Constructors

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
	return [self initWithURL:url context:aContext userData:nil];
}

- (id)initWithURL:(NSURL *)url context:(TMDB *)aContext userData:(NSDictionary *)userData
{
	if ((self = [self init]))
	{
		_context = aContext;

		_rawResults = nil;

		_id = 0;
		_userData = [userData retain];
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
		
		// Initialize the fetch request
		_request = [TMDBRequest requestWithURL:url delegate:self];
	}

	return self;
}

- (id)initWithID:(NSInteger)anID context:(TMDB *)aContext
{
	NSURL *url = [NSURL URLWithString:[API_URL_BASE stringByAppendingFormat:@"%.1f/Movie.getInfo/%@/json/%@/%li",
									   API_VERSION, aContext.language, aContext.apiKey, anID]];
	return [self initWithURL:url context:aContext];
}

- (id)initWithName:(NSString *)aName context:(TMDB *)aContext
{
	NSString *aNameEscaped = [aName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[API_URL_BASE stringByAppendingFormat:@"%.1f/Movie.search/%@/json/%@/%@",
									   API_VERSION, aContext.language, aContext.apiKey, aNameEscaped]];
	return [self initWithURL:url context:aContext userData:[NSDictionary dictionaryWithObject:aName forKey:@"title"]];
}

#pragma mark -

- (NSString *)description
{
	if (!self.title)
		return [NSString stringWithFormat:@"<%@>", [self class], nil];

	if (!self.released)
		return [NSString stringWithFormat:@"<%@: %@>", [self class], self.title, nil];

	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *weekdayComponents = [cal components:NSYearCalendarUnit fromDate:self.released];
	NSInteger year = [weekdayComponents year];
	[cal release];

	return [NSString stringWithFormat:@"<%@: %@ (%i)>", [self class], self.title, year, nil];
}

#pragma mark -
#pragma mark TMDBRequestDelegate
- (void)request:(TMDBRequest *)request didFinishLoading:(NSError *)error
{
	if (error)
	{
		NSLog(@"iTMDb: TMDBMovie request failed: %@", [error description]);
		if (_context)
			[_context movieDidFailLoading:self error:error];
		return;
	}

	_rawResults = [[NSArray alloc] initWithArray:(NSArray *)[request parsedData] copyItems:YES];

	if (![[_rawResults objectAtIndex:0] isKindOfClass:[NSDictionary class]])
	{
		//NSLog(@"iTMDb: Returned data is NOT a dictionary!\n%@", _rawResults);
		if (_context)
		{
			NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSString stringWithFormat:@"The data source (themoviedb) returned invalid data: %@", _rawResults],
									   NSLocalizedDescriptionKey,
									   nil];
			NSError *failError = [NSError errorWithDomain:@"Invalid data"
													 code:0
												 userInfo:errorDict];
			[_context movieDidFailLoading:self error:failError];
		}
		return;
	}

	NSDictionary *d = [_rawResults objectAtIndex:0];

	// SIMPLE DATA

	_id       = [(NSNumber *)[d objectForKey:@"name"] integerValue];
	_title    = [[d objectForKey:@"name"] copy];
	_overview = [[d objectForKey:@"overview"] copy];
	_tagline  = [[d objectForKey:@"tagline"] copy];
	_imdbID   = [[d objectForKey:@"imdb_id"] copy];

	// COMPLEX DATA

	// Release date
	if ([d objectForKey:@"released"])
	{
		NSDateFormatter *releasedFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[releasedFormatter setDateFormat:@"yyyy-MM-dd"];
		_released = [[releasedFormatter dateFromString:(NSString *)[d objectForKey:@"released"]] retain];
	}

	// Runtime
	if (!([d objectForKey:@"runtime"] == nil || [[d objectForKey:@"runtime"] isKindOfClass:[NSNull class]]))
		_runtime  = [[d objectForKey:@"runtime"] unsignedIntegerValue];

	// Homepage
	if ([d objectForKey:@"homepage"])
		_homepage = [[NSURL URLWithString:[d objectForKey:@"homepage"]] retain];
	else
		_homepage = nil;

	// Posters
	_posters = nil;
	if ([d objectForKey:@"posters"])
		_posters = [[self arrayWithImages:[d objectForKey:@"posters"] ofType:TMDBImageTypePoster] retain];
	//NSLog(@"POSTERS %@", _posters);

	// Backdrops
	_backdrops = nil;
	if ([d objectForKey:@"backdrops"])
		_backdrops = [[self arrayWithImages:[d objectForKey:@"backdrops"] ofType:TMDBImageTypeBackdrop] retain];
	//NSLog(@"BACKDROPS %@", _backdrops);

	// Notify the context that the movie info has been loaded
	if (_context)
		[_context movieDidFinishLoading:self];
}

- (NSArray *)arrayWithImages:(NSArray *)theImages ofType:(TMDBImageType)aType {
	NSMutableArray *imageObjects = [[NSMutableArray arrayWithCapacity:0] retain];

	TMDBImage *currentImage = nil;
	// outerImageDict: the TMDb API wraps each image in a wrapper dictionary (e.g. each backdrop has an "images" dictionary)
	for (NSDictionary *outerImageDict in theImages)
	{
		// innerImageDict: the image info (see outerImageDict)
		NSDictionary *innerImageDict = [outerImageDict objectForKey:@"image"];

		// Fetch the existing image (if any)
		BOOL allocatedNewObject = NO;
		if (currentImage && ![currentImage.id isEqualToString:[innerImageDict objectForKey:@"id"]])
		{
			// Warning: This hasn't actually been tested yet
			NSIndexSet *passed = [imageObjects indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
				TMDBImage *lookupImage = (TMDBImage *)obj;
				BOOL passed = [lookupImage.id isEqualToString:[innerImageDict objectForKey:@"id"]];
				if (passed) // we only need one object
					*(stop) = YES;
				return passed;
			}];

			if ([passed count] > 0 && imageObjects)
				currentImage = [imageObjects objectAtIndex:[passed firstIndex]];
			else
				currentImage = nil;
		}

		// use !currentBackdrop instead of an else, as an object recovery (fetch) may have been performed
		if (!currentImage)
		{
			currentImage = [[[TMDBImage alloc] initWithId:[innerImageDict objectForKey:@"id"] ofType:aType] retain];
			allocatedNewObject = YES;
		}

		TMDBImageSize imgSize = -1;
		NSString *imgSizeString = [innerImageDict objectForKey:@"size"];
		if ([imgSizeString isEqualToString:@"original"])
			imgSize = TMDBImageSizeOriginal;
		else if ([imgSizeString isEqualToString:@"mid"])
			imgSize = TMDBImageSizeMid;
		else if ([imgSizeString isEqualToString:@"cover"])
			imgSize = TMDBImageSizeCover;
		else if ([imgSizeString isEqualToString:@"thumb"])
			imgSize = TMDBImageSizeThumb;

		[currentImage setURL:[NSURL URLWithString:[innerImageDict objectForKey:@"url"]] forSize:imgSize];

		// Add object if it doesn't already exist
		if (allocatedNewObject)
			[imageObjects addObject:currentImage];
	}
	return imageObjects;
}

#pragma mark -
- (void)dealloc {
	//printf("iTMDb: TMDBMovie dealloc\n");
	[_request release];
	[_userData release];
	[_rawResults release];
	[_title release];
	[_released release];
	[_overview release];
	[_tagline release];
	[_homepage release];
	[_imdbID release];

	[super dealloc];
}

@end