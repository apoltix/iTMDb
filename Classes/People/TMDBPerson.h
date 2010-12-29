//
//  TMDBPerson.h
//  iTMDb
//
//  Created by Christian Rasmussen on 29/12/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TMDBMovie;

@interface TMDBPerson : NSObject {
	NSUInteger _id;
	NSString *_name;
	NSString *_character;
	TMDBMovie *_movie;
	NSString *_job;
	NSURL *_url;
	NSInteger _order;
	NSInteger _castID;
}

@property (nonatomic, assign, readonly) NSUInteger id;
@property (nonatomic, retain, readonly) NSString *name;
@property (nonatomic, retain, readonly) NSString *character;
@property (nonatomic, retain, readonly) TMDBMovie *movie;
@property (nonatomic, retain, readonly) NSString *job;
@property (nonatomic, retain, readonly) NSURL *url;
@property (nonatomic, assign, readonly) NSInteger order;
@property (nonatomic, assign, readonly) NSInteger castID;

+ (NSArray *)personsWithMovie:(TMDBMovie *)movie personsInfo:(NSArray *)personsInfo;

- (id)initWithMovie:(TMDBMovie *)movie personInfo:(NSDictionary *)personInfo;

@end