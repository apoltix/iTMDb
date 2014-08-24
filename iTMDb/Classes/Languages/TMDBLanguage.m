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

+ (NSArray *)languagesFromArrayOfDictionaries:(NSArray *)rawLanguagesDictionaries {
	if (rawLanguagesDictionaries == nil) {
		return nil;
	}

	if (![rawLanguagesDictionaries isKindOfClass:[NSArray class]]) {
		NSDictionary *userInfo = @{
			@"object": rawLanguagesDictionaries
		};

		@throw [NSException exceptionWithName:NSInvalidArgumentException
									   reason:@"Parameter rawLanguagesDictionary must be an NSArray instance."
									 userInfo:userInfo];
	}

	if (rawLanguagesDictionaries.count == 0) {
		return @[];
	}

	NSMutableArray *languages = [NSMutableArray array];

	for (NSDictionary *rawLanguage in rawLanguagesDictionaries) {
		TMDBLanguage *language = [[TMDBLanguage alloc] initWithDictionary:rawLanguage];

		if (language != nil) {
			[languages addObject:language];
		}
	}

	return [languages copy];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	if (!(self = [super init])) {
		return nil;
	}

	_name = TMDB_NSStringOrNil(dictionary[@"name"]);
	_iso639_1 = TMDB_NSStringOrNil(dictionary[@"iso_639_1"]);

	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@ %p: \"%@\" (%@)>", NSStringFromClass(self.class), self, self.name, self.iso639_1];
}

@end
