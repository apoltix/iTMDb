//
//  TMDBRequest.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMDBRequestDelegate.h"

typedef void (^TMDBRequestCompletionBlock)(id parsedData);

@interface TMDBRequest : NSObject

@property (nonatomic, weak, readonly) id<TMDBRequestDelegate> delegate;

+ (TMDBRequest *)requestWithURL:(NSURL *)url delegate:(id<TMDBRequestDelegate>)delegate;
+ (TMDBRequest *)requestWithURL:(NSURL *)url completionBlock:(TMDBRequestCompletionBlock)block;

- (id)initWithURL:(NSURL *)url delegate:(id<TMDBRequestDelegate>)delegate;
- (id)initWithURL:(NSURL *)url completionBlock:(TMDBRequestCompletionBlock)block;

@property (nonatomic, copy, readonly) NSURLResponse *response;
- (id)parsedData;

@end