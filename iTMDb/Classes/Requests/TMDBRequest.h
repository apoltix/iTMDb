//
//  TMDBRequest.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

@import Foundation;

typedef void (^TMDBRequestCompletionBlock)(id parsedData, NSError *error);

// Private class
@interface TMDBRequest : NSObject

+ (instancetype)requestWithURL:(NSURL *)url completionBlock:(TMDBRequestCompletionBlock)block;
- (instancetype)initWithURL:(NSURL *)url completionBlock:(TMDBRequestCompletionBlock)block NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, readonly) TMDBRequestCompletionBlock completionBlock;

@property (nonatomic, copy, readonly) NSURLResponse *response;
- (id)parsedData;

@end
