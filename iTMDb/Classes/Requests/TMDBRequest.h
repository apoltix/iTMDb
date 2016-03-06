//
//  TMDBRequest.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright (c) 2010 Devify. All rights reserved.
//

@import Foundation;

typedef void (^TMDBRequestCompletionBlock)(id _Nullable parsedData, NSError * _Nullable error);

// Private class
@interface TMDBRequest : NSOperation

+ (nonnull NSOperationQueue *)operationQueue;

/**
 * Creates and returns a new request operation, and adds it to the operation
 * queue.
 */
+ (nullable instancetype)requestWithURL:(nonnull NSURL *)url completionBlock:(nullable TMDBRequestCompletionBlock)block;

/**
 * Instantiates a new request operation. You are responsible for adding it to
 * the operation queue.
 */
- (nullable instancetype)initWithURL:(nonnull NSURL *)url completionBlock:(nullable TMDBRequestCompletionBlock)block NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

/**
 * The completion block passed during initialization.
 */
@property (nonatomic, copy, nullable, readonly) TMDBRequestCompletionBlock requestCompletionBlock;

@property (nonatomic, copy, nullable, readonly) NSURL *url;

@property (nonatomic, copy, nullable, readonly) NSURLResponse *response;
@property (nonatomic, copy, nullable, readonly) NSError *error;
@property (nonatomic, strong, nullable, readonly) id parsedData;

@end
