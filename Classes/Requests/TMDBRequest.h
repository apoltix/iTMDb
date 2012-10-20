//
//  TMDBRequest.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMDBRequestDelegate.h"

@interface TMDBRequest : NSObject {
@protected
	NSMutableData *_data;
	__weak id<TMDBRequestDelegate> _delegate;
	void (^_completionBlock)(NSDictionary *parsedData);
}

@property (nonatomic, weak, readonly) id<TMDBRequestDelegate> delegate;

+ (TMDBRequest *)requestWithURL:(NSURL *)url delegate:(id<TMDBRequestDelegate>)delegate;
+ (TMDBRequest *)requestWithURL:(NSURL *)url completionBlock:(void (^)(NSDictionary *parsedData))block;

- (id)initWithURL:(NSURL *)url delegate:(id<TMDBRequestDelegate>)delegate;
- (id)initWithURL:(NSURL *)url completionBlock:(void (^)(NSDictionary *parsedData))block;

- (NSDictionary *)parsedData;

@end