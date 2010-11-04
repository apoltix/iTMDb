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

@synthesize context, rawResults=_rawResults, title=_title,
			overview=_overview, runtime=_runtime, tagline=_tagline;

+ (TMDBMovie *)movieWithID:(NSInteger)anID context:(TMDB *)aContext
{
	return [[[TMDBMovie alloc] initWithID:anID context:aContext] autorelease];
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
		_request = [TMDBRequest requestWithURL:requestURL
									  delegate:self];
		
	}

	return nil;
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

	_rawResults = (NSArray *)[request parsedData];

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

	_title    = [d objectForKey:@"name"];
	_overview = [d objectForKey:@"overview"];
	_runtime  = [[d objectForKey:@"runtime"] unsignedIntegerValue];
	_tagline  = [d objectForKey:@"tagline"];

	if (_context)
		[_context movieDidFinishLoading:self];
}

@end