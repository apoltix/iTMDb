//
//  TMDBMovie.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import "TMDB.h"
#import "TMDBMovie.h"

@implementation TMDBMovie

@synthesize context,
            rawResults=_rawResults,
            id=_id,
            title=_title,
            released=_released,
            overview=_overview,
            runtime=_runtime,
            tagline=_tagline,
            homepage=_homepage,
            imdbID=_imdbID;

+ (TMDBMovie *)movieWithID:(NSInteger)anID context:(TMDB *)aContext
{
	return [[TMDBMovie alloc] initWithID:anID context:aContext];
}

- (id)initWithID:(NSInteger)anID context:(TMDB *)aContext
{
	if ((self = [self init]))
	{
		_context = aContext;

		_rawResults = nil;
		_title = nil;
		_overview = nil;
		_runtime = 0;
		_tagline = nil;

		// Initialize the fetch request
		NSURL *requestURL = [NSURL URLWithString:[API_URL_BASE stringByAppendingFormat:@"%.1f/Movie.getInfo/%@/json/%@/%li",
												  API_VERSION, _context.language, _context.apiKey, anID]];
		_request = [TMDBRequest requestWithURL:requestURL delegate:self];
		
	}

	return nil;
}

- (NSString *)description
{
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *weekdayComponents = [cal components:NSYearCalendarUnit fromDate:self.released];
	NSInteger year = [weekdayComponents year];
	[cal release];

	return [NSString stringWithFormat:@"<%@: %@ (%i)>", [self class], self.title, year, nil];
}

#pragma mark TMDBRequestDelegate
- (void)request:(TMDBRequest *)request didFinishLoading:(NSError *)error
{
	if (error)
	{
		NSLog(@"TMDBMovie request failed: %@", [error description]);
		if (_context)
			[_context movieDidFailLoading:self error:error];
		return;
	}

	_rawResults = [[NSArray alloc] initWithArray:(NSArray *)[request parsedData] copyItems:YES];

	if (![[_rawResults objectAtIndex:0] isKindOfClass:[NSDictionary class]])
	{
		NSLog(@"Returned data is NOT a dictionary!\n%@", _rawResults);
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

	_id       = [(NSNumber *)[d objectForKey:@"name"] integerValue];
	_title    = [[d objectForKey:@"name"] copy];
	_overview = [[d objectForKey:@"overview"] copy];
	_tagline  = [[d objectForKey:@"tagline"] copy];
	_homepage = [NSURL URLWithString:[d objectForKey:@"homepage"]];
	_imdbID   = [[d objectForKey:@"imdb_id"] copy];

	NSDateFormatter *releasedFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[releasedFormatter setDateFormat:@"yyyy-MM-dd"];
	_released = [releasedFormatter dateFromString:(NSString *)[d objectForKey:@"released"]];

	if (!([d objectForKey:@"runtime"] == nil || [[d objectForKey:@"runtime"] isKindOfClass:[NSNull class]]))
		_runtime  = [[d objectForKey:@"runtime"] unsignedIntegerValue];

	if (_context)
		[_context movieDidFinishLoading:self];
}

#pragma mark -
- (void)dealloc {
	//printf("dealloc\n");
	[_request release];
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