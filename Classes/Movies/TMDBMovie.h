//
//  TMDBMovie.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TMDB;

#import "TMDBRequest.h"
#import "TMDBRequestDelegate.h"

@interface TMDBMovie : NSObject <TMDBRequestDelegate> {
	TMDB			*_context;
	TMDBRequest		*_request;

	NSDictionary	*_userData;
	NSInteger		_id;
	NSArray			*_rawResults;
	NSString		*_title;
	NSDate			*_released;
	NSString		*_overview;
	NSUInteger		_runtime;
	NSString		*_tagline;
	NSURL			*_homepage;
	NSString		*_imdbID;
	NSArray			*_posters;
	NSArray			*_backdrops;
	float			_rating;
	NSUInteger		_budget;
	NSInteger		_revenue;
	NSURL			*_trailer;
	NSArray			*_studios;
	NSString		*_originalName;
	NSString		*_alternativeName;
	NSInteger		_popularity;
	BOOL			_translated;
	BOOL			_adult;
	NSString		*_language;
	NSURL			*_url;
	NSInteger		_votes;
	NSString		*_certification;
	NSArray			*_categories;
	NSArray			*_keywords;
	NSArray			*_languagesSpoken;
	NSArray			*_countries;
	NSArray			*_cast;
	NSUInteger		_version;
	NSDate			*_modified;

	BOOL			isSearchingOnly;
}

@property (nonatomic, retain, readonly) TMDB			*context;

@property (nonatomic, retain, readonly) NSArray			*rawResults;
@property (nonatomic, retain, readonly) NSDictionary	*userData;
@property (nonatomic, assign, readonly) NSInteger		id;
@property (nonatomic, retain, readonly) NSString		*title;
@property (nonatomic, retain, readonly) NSDate			*released;
@property (nonatomic, assign, readonly) NSUInteger		year;
@property (nonatomic, retain, readonly) NSString		*overview;
@property (nonatomic, assign, readonly) NSUInteger		runtime;
@property (nonatomic, retain, readonly) NSString		*tagline;
@property (nonatomic, retain, readonly) NSURL			*homepage;
@property (nonatomic, retain, readonly) NSString		*imdbID;
@property (nonatomic, retain, readonly) NSArray			*posters;
@property (nonatomic, retain, readonly) NSArray			*backdrops;
@property (nonatomic, retain, readonly) NSString		*language;
@property (nonatomic, assign, readonly) BOOL			translated;
@property (nonatomic, assign, readonly) BOOL			adult;
@property (nonatomic, retain, readonly) NSURL			*url;
@property (nonatomic, assign, readonly) NSInteger		votes;
@property (nonatomic, retain, readonly) NSString		*certification;
@property (nonatomic, retain, readonly) NSArray			*categories;
@property (nonatomic, retain, readonly) NSArray			*keywords;
@property (nonatomic, retain, readonly) NSArray			*languagesSpoken;
@property (nonatomic, retain, readonly) NSArray			*countries;
@property (nonatomic, retain, readonly) NSArray			*cast;

+ (TMDBMovie *)movieWithID:(NSInteger)anID context:(TMDB *)context;
+ (TMDBMovie *)movieWithName:(NSString *)aName context:(TMDB *)context;

- (id)initWithID:(NSInteger)anID context:(TMDB *)context;
- (id)initWithName:(NSString *)aName context:(TMDB *)context;

@end