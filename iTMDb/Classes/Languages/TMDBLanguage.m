//
//  TMDBLanguage.m
//  iTMDb
//
//  Created by Christian Rasmussen on 10/08/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

#import "TMDBLanguage.h"
#import "TMDB.h"

@implementation TMDBLanguage

+ (NSArray *)languagesFromArrayOfDictionaries:(NSArray *)rawLanguagesDictionaries context:(TMDB *)context {
	if (rawLanguagesDictionaries == nil) {
		return nil;
	}

	if (![rawLanguagesDictionaries isKindOfClass:[NSArray class]]) {
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Parameter rawLanguagesDictionary must be an NSArray instance." userInfo:@{@"object": rawLanguagesDictionaries}];
	}

	if ([rawLanguagesDictionaries count] == 0) {
		return @[];
	}

	if (context == nil || ![context isKindOfClass:[TMDB class]]) {
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Parameter context must be an instance of `TMDB`." userInfo:context ? @{@"object": context} : nil];
	}

	NSMutableArray *languages = [NSMutableArray array];

	for (NSDictionary *rawLanguage in rawLanguagesDictionaries) {
		TMDBLanguage *language = [[TMDBLanguage alloc] initWithDictionary:rawLanguage context:context];

		if (language) {
			[languages addObject:language];
		}
	}

	return [languages copy];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary context:(TMDB *)context {
	if (!(self = [super init])) {
		return nil;
	}

	_context = context;
	_name = TMDB_NSStringOrNil(dictionary[@"name"]);
	_iso639_1 = TMDB_NSStringOrNil(dictionary[@"iso_639_1"]);

	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@ %p: \"%@\" (%@)>", NSStringFromClass(self.class), self, self.name, self.iso639_1];
}

@end