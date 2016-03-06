//
//  TMDBDataValidation.h
//  iTMDb
//
//  Created by Christian Rasmussen on 10/08/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

@import Foundation;

static inline _Nullable id TMDB_ObjectOfClassOrNil(id _Nullable objectOrNil, Class _Nonnull expectedClass) {
	if (objectOrNil == nil || ![objectOrNil isKindOfClass:expectedClass]) {
		return nil;
	}

	return objectOrNil;
}

static inline NSString * _Nullable TMDB_NSStringOrNil(NSString * _Nullable stringOrNil) {
	return TMDB_ObjectOfClassOrNil(stringOrNil, [NSString class]);
}

static inline NSNumber * _Nullable TMDB_NSNumberOrNil(NSNumber * _Nullable numberOrNil) {
	return TMDB_ObjectOfClassOrNil(numberOrNil, [NSNumber class]);
}

static inline NSURL * _Nullable TMDB_NSURLOrNilFromStringOrNil(NSString * _Nullable urlStringOrNil) {
	if (TMDB_NSStringOrNil(urlStringOrNil) == nil || urlStringOrNil.length == 0) {
		return nil;
	}

	return [NSURL URLWithString:urlStringOrNil];
}

static inline NSArray * _Nullable TMDB_NSArrayOrNil(NSArray * _Nullable arrayOrNil) {
	return TMDB_ObjectOfClassOrNil(arrayOrNil, [NSArray class]);
}

static inline NSDictionary * _Nullable TMDB_NSDictionaryOrNil(NSDictionary * _Nullable dictionaryOrNil) {
	return TMDB_ObjectOfClassOrNil(dictionaryOrNil, [NSDictionary class]);
}
