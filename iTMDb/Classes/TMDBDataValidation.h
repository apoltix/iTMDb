//
//  TMDBDataValidation.h
//  iTMDb
//
//  Created by Christian Rasmussen on 10/08/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

@import Foundation;

static inline id TMDB_ObjectOfClassOrNil(id objectOrNil, Class expectedClass) {
	if (objectOrNil == nil || ![objectOrNil isKindOfClass:expectedClass]) {
		return nil;
	}

	return objectOrNil;
}

static inline NSString *TMDB_NSStringOrNil(NSString *stringOrNil) {
	return TMDB_ObjectOfClassOrNil(stringOrNil, [NSString class]);
}

static inline NSNumber *TMDB_NSNumberOrNil(NSNumber *numberOrNil) {
	return TMDB_ObjectOfClassOrNil(numberOrNil, [NSNumber class]);
}

static inline NSURL *TMDB_NSURLOrNilFromStringOrNil(NSString *urlString) {
	if (TMDB_NSStringOrNil(urlString) == nil || [urlString length] == 0) {
		return nil;
	}

	return [NSURL URLWithString:urlString];
}

static inline NSArray *TMDB_NSArrayOrNil(NSArray *arrayOrNil) {
	return TMDB_ObjectOfClassOrNil(arrayOrNil, [NSArray class]);
}

static inline NSDictionary *TMDB_NSDictionaryOrNil(NSDictionary *dictionaryOrNil) {
	return TMDB_ObjectOfClassOrNil(dictionaryOrNil, [NSDictionary class]);
}
