//
//  TMDBConfiguration.m
//  iTMDb
//
//  Created by Christian Rasmussen on 09/08/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

#import "TMDBConfiguration.h"
#import "TMDB.h"
#import "TMDBRequest.h"

@interface TMDBConfiguration () <TMDBRequestDelegate>

@property (nonatomic, getter=isLoaded) BOOL loaded;

@property (nonatomic, copy) NSURL *imagesBaseURL;
@property (nonatomic, copy) NSURL *imagesSecureBaseURL;

@property (nonatomic, copy) NSArray *imagesPosterSizes;
@property (nonatomic, copy) NSArray *imagesBackdropSizes;
@property (nonatomic, copy) NSArray *imagesProfileSizes;
@property (nonatomic, copy) NSArray *imagesLogoSizes;

@property (nonatomic, copy) NSArray *changeKeys;

@end

@implementation TMDBConfiguration

@synthesize loaded=_isLoaded;

- (instancetype)initWithContext:(TMDB *)context
{
	if (!(self = [super init]))
		return nil;

	_context = context;

	NSString *configURLString = [NSString stringWithFormat:@"%@%@/configuration?api_key=%@", TMDBAPIURLBase, TMDBAPIVersion, context.apiKey];
	NSURL *configURL = [NSURL URLWithString:configURLString];
	if (![TMDBRequest requestWithURL:configURL delegate:self])
		TMDBLog(@"Could not create request for configuration.");

	return self;
}

#pragma mark - TMDBRequestDelegate

- (void)request:(TMDBRequest *)request didFinishLoading:(NSError *)error
{
	if (error != nil)
	{
		TMDBLog(@"Configuration fetch request failed with error: %@", error);
		return;
	}

	if (request.parsedData == nil || ![request.parsedData isKindOfClass:[NSDictionary class]])
	{
		TMDBLog(@"Configuration response was empty or invalid.");
		return;
	}

	[self populateWithDictionary:(NSDictionary *)request.parsedData];

	self.loaded = YES;
}

- (void)populateWithDictionary:(NSDictionary *)d
{
	self.imagesBaseURL = TMDB_NSURLOrNilFromStringOrNil(d[@"images"][@"base_url"]);
	self.imagesSecureBaseURL = TMDB_NSURLOrNilFromStringOrNil(d[@"images"][@"secure_base_url"]);

	self.imagesPosterSizes = TMDB_NSArrayOrNil(d[@"images"][@"poster_sizes"]);
	self.imagesBackdropSizes = TMDB_NSArrayOrNil(d[@"images"][@"backdrop_sizes"]);
	self.imagesProfileSizes = TMDB_NSArrayOrNil(d[@"images"][@"profile_sizes"]);
	self.imagesLogoSizes = TMDB_NSArrayOrNil(d[@"images"][@"logo_sizes"]);

	self.changeKeys = TMDB_NSArrayOrNil(d[@"change_keys"]);
}

@end