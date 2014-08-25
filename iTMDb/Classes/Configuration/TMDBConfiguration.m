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

@interface TMDBConfiguration ()

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

- (void)reload:(void (^)(NSError *error))completionBlock {
	TMDB *context = [TMDB sharedInstance];

	NSString *configURLString = [NSString stringWithFormat:@"%@%@/configuration?api_key=%@", TMDBAPIURLBase, TMDBAPIVersion, context.apiKey];
	NSURL *configURL = [NSURL URLWithString:configURLString];

	TMDBRequest *request = [TMDBRequest requestWithURL:configURL completionBlock:^(id parsedData, NSError *error) {
		if (error != nil) {
			if (completionBlock != nil) {
				completionBlock(error);
			}
			return;
		}

		if (parsedData == nil || ![parsedData isKindOfClass:[NSDictionary class]]) {
			TMDBLog(@"Configuration response was empty or invalid.");
			// TODO: Create error object and call completion block
			return;
		}

		[self populateWithDictionary:(NSDictionary *)parsedData];

		self.loaded = YES;

		if (completionBlock != nil) {
			completionBlock(nil);
		}
	}];

	if (request == nil) {
		TMDBLog(@"Could not create request for configuration.");
	}
}

#pragma mark -

- (void)populateWithDictionary:(NSDictionary *)d {
	self.imagesBaseURL = TMDB_NSURLOrNilFromStringOrNil(d[@"images"][@"base_url"]);
	self.imagesSecureBaseURL = TMDB_NSURLOrNilFromStringOrNil(d[@"images"][@"secure_base_url"]);

	self.imagesPosterSizes = TMDB_NSArrayOrNil(d[@"images"][@"poster_sizes"]);
	self.imagesBackdropSizes = TMDB_NSArrayOrNil(d[@"images"][@"backdrop_sizes"]);
	self.imagesProfileSizes = TMDB_NSArrayOrNil(d[@"images"][@"profile_sizes"]);
	self.imagesLogoSizes = TMDB_NSArrayOrNil(d[@"images"][@"logo_sizes"]);

	self.changeKeys = TMDB_NSArrayOrNil(d[@"change_keys"]);
}

@end
