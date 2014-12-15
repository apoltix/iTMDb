//
//  TMDBMovieSearch.m
//  iTMDb
//
//  Created by Christian Rasmussen on 25/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "TMDBMovieSearch.h"
#import "TMDB.h"
#import "TMDBRequest.h"
#import "TMDBError.h"

@implementation TMDBMovieSearch

- (instancetype)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
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

+ (NSURL *)fetchURLWithMovieID:(NSUInteger)tmdbID options:(TMDBMovieFetchOptions)options {
	TMDB *context = [TMDB sharedInstance];
	NSString *apiKey = context.apiKey,
			 *language = context.language,
			 *additionalQueries = [self appendToResponseStringFromFetchOptions:options];

	NSString *urlString = [TMDBAPIURLBase stringByAppendingFormat:@"%@/movie/%tu?api_key=%@&language=%@%@", TMDBAPIVersion, tmdbID, apiKey, language, additionalQueries];

	return [NSURL URLWithString:urlString];
}

+ (NSURL *)searchURLWithMovieTitle:(NSString *)title year:(NSUInteger)year {
	TMDB *context = [TMDB sharedInstance];

	NSString *apiKey = context.apiKey,
			 *language = context.language,
			 *titleEscaped = [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSString *yearQuery = year > 0 ? [NSString stringWithFormat:@"&year=%lu", year] : @"";

	NSString *urlString = [TMDBAPIURLBase stringByAppendingFormat:@"%@/search/movie?api_key=%@&query=%@%@&language=%@",
						   TMDBAPIVersion, apiKey, titleEscaped, yearQuery, language];

	return [NSURL URLWithString:urlString];
}

#pragma mark - Searching

+ (void)moviesWithTitle:(NSString *)title completion:(TMDBMoviesFetchCompletionBlock)completionBlock {
	[self moviesWithTitle:title year:0 completion:completionBlock];
}

+ (void)moviesWithTitle:(NSString *)title year:(NSUInteger)year completion:(TMDBMoviesFetchCompletionBlock)completionBlock {
	NSURL *url = [TMDBMovieSearch searchURLWithMovieTitle:title year:year];

	if (url == nil) {
		if (completionBlock != nil) {
			NSError *error = [NSError errorWithDomain:TMDBErrorDomain
												 code:TMDBErrorCodeInvalidURL
											 userInfo:nil];
			completionBlock(nil, error);
		}
		return;
	}

	[TMDBMovieSearch loadSearchURL:url completion:completionBlock];
}

#pragma mark - Fetching

// Private
+ (void)loadSearchURL:(NSURL *)url completion:(TMDBMoviesFetchCompletionBlock)completionBlock {
	[TMDBRequest requestWithURL:url completionBlock:^(id parsedData, NSError *error) {
		if (error != nil) {
			if (completionBlock != nil) {
				completionBlock(nil, error);
			}
			return;
		}

		NSError *error2 = nil;
		NSArray *movies = [TMDBMovieSearch moviesFromSearchData:parsedData error:&error2];

		if (completionBlock != nil) {
			completionBlock(movies, error2);
		}
	}];
}

#pragma mark - Parsing

// Private
+ (NSArray *)moviesFromSearchData:(NSDictionary *)parsedData error:(NSError **)outError {
	NSArray *rawResults = (NSArray *)parsedData[@"results"];

	if (rawResults == nil || rawResults.count == 0 || ![rawResults.firstObject isKindOfClass:[NSDictionary class]]) {
		if (outError != nil) {
			NSDictionary *errorDict = @{
				NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The data source (themoviedb) returned invalid data: %@", rawResults]
			};

			*outError = [NSError errorWithDomain:TMDBErrorDomain
											code:TMDBErrorCodeReceivedInvalidData
										userInfo:errorDict];
		}

		return nil;
	}

	NSMutableArray *movies = [NSMutableArray array];

	for (NSDictionary *rawResult in rawResults) {
		if (TMDB_NSDictionaryOrNil(rawResult) == nil) {
			continue;
		}

		TMDBMovie *movie = [[TMDBMovie alloc] init];
		[movie populate:rawResult];

		if (movie != nil) {
			[movies addObject:movie];
		}
	}

	return movies;
}

+ (NSDictionary *)movieDataFromRawResults:(NSArray *)rawResults searching:(BOOL)isSearching expectedYear:(NSUInteger)expectedYear {
	NSDictionary *d = nil;

	// If there are multiple results, and the user specified an expected year
	// of release iterate over the search results and find the one matching
	// said year, if any.
	if (isSearching && expectedYear != 0) {
		for (NSDictionary *result in rawResults) {
			NSDate *releaseDate = [TMDBMovie dateFromString:(NSString *)result[@"release_date"]];
			NSUInteger releaseYear = [TMDBMovie yearFromDate:releaseDate];

			if (releaseYear == expectedYear) {
				d = result;
				break;
			}
		}
	}

	return d;
}

@end
