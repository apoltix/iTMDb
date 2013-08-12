//
//  TMDBRequest.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TMDBRequestDelegate;

typedef void (^TMDBRequestCompletionBlock)(id parsedData);

@interface TMDBRequest : NSObject

@property (nonatomic, weak, readonly) id<TMDBRequestDelegate> delegate;
@property (nonatomic, copy, readonly) TMDBRequestCompletionBlock completionBlock;

+ (instancetype)requestWithURL:(NSURL *)url delegate:(id<TMDBRequestDelegate>)delegate;
+ (instancetype)requestWithURL:(NSURL *)url completionBlock:(TMDBRequestCompletionBlock)block;

- (instancetype)initWithURL:(NSURL *)url delegate:(id<TMDBRequestDelegate>)delegate;
- (instancetype)initWithURL:(NSURL *)url completionBlock:(TMDBRequestCompletionBlock)block;

@property (nonatomic, copy, readonly) NSURLResponse *response;
- (id)parsedData;

@end

@protocol TMDBRequestDelegate <NSObject>

@required

/**
 * Called when a TMDBRequest is finished and the data has been loaded, or an error occured.
 */
- (void)request:(TMDBRequest *)request didFinishLoading:(NSError *)error;

@end