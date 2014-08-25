//
//  TMDBRequest.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright (c) 2010 Devify. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TMDBRequestCompletionBlock)(id parsedData, NSError *error);

// Private class
@interface TMDBRequest : NSOperation

+ (NSOperationQueue *)operationQueue;

/**
 * Creates and returns a new request operation, and adds it to the operation
 * queue.
 */
+ (instancetype)requestWithURL:(NSURL *)url completionBlock:(TMDBRequestCompletionBlock)block;

/**
 * Instantiates a new request operation. You are responsible for adding it to
 * the operation queue.
 */
- (instancetype)initWithURL:(NSURL *)url completionBlock:(TMDBRequestCompletionBlock)block NS_DESIGNATED_INITIALIZER;

/**
 * The completion block passed during initialization.
 */
@property (nonatomic, copy, readonly) TMDBRequestCompletionBlock requestCompletionBlock;

@property (nonatomic, copy, readonly) NSURL *url;

@property (nonatomic, copy, readonly) NSURLResponse *response;
@property (nonatomic, copy, readonly) NSError *error;
@property (nonatomic, strong, readonly) id parsedData;

@end
