//
//  TMDBRequest.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright (c) 2010 Devify. All rights reserved.
//

#import "TMDBRequest.h"

@interface TMDBRequest () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@end

@implementation TMDBRequest {
@private
	NSMutableData *_responseData;
	id _parsedData;
}

@synthesize executing=_isExecuting, finished=_isFinished;

+ (NSOperationQueue *)operationQueue {
	static NSOperationQueue *sharedQueue;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedQueue = [[NSOperationQueue alloc] init];
		sharedQueue.name = [NSStringFromClass(self) stringByAppendingString:@"Queue"];
		sharedQueue.maxConcurrentOperationCount = 4;
	});
	return sharedQueue;
}

+ (instancetype)requestWithURL:(NSURL *)url completionBlock:(TMDBRequestCompletionBlock)block {
	TMDBRequest *request = [[TMDBRequest alloc] initWithURL:url completionBlock:block];
	[[TMDBRequest operationQueue] addOperation:request];
	return request;
}

- (instancetype)initWithURL:(NSURL *)url completionBlock:(TMDBRequestCompletionBlock)block {
	NSParameterAssert(url != nil);

	if (!(self = [super init])) {
		return nil;
	}

	self.name = url.description;
	_url = [url copy];
	_requestCompletionBlock = [block copy];

	return self;
}

#pragma mark - NSOperation

- (BOOL)isConcurrent {
	return YES;
}

- (void)start {
	if (self.isCancelled) {
		[self finish];
		return;
	}

	_responseData = [NSMutableData data];

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:self.url
													   cachePolicy:NSURLRequestUseProtocolCachePolicy
												   timeoutInterval:30.0];

	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req
															delegate:self
													startImmediately:NO];

	[conn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[conn start];

	TMDBSetIvarValue(isExecuting, _isExecuting, YES);
	TMDBSetIvarValue(isFinished, _isFinished, NO);
}

#pragma mark -

- (id)parsedData {
	if (_parsedData != nil) {
		return _parsedData;
	}

	NSError *error = nil;
	id parsedData = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:&error];
	if (error != nil) {
		TMDBLog(@"iTMDb: Error parsing JSON data: %@", error);
		TMDBSetValue(error, error);
	}

	_parsedData = parsedData;

	return parsedData;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	_response = [response copy];
	_parsedData = nil;
	_responseData.length = 0;

	if (self.isCancelled) {
		[connection cancel];
		[self finish];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)thedata {
	[_responseData appendData:thedata];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	_responseData = nil;
	_parsedData = nil;
	TMDBSetValue(error, error);

	[self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self finish];
}

#pragma mark -

- (void)finish {
	TMDBSetIvarValue(isExecuting, _isExecuting, NO);
	TMDBSetIvarValue(isFinished, _isFinished, YES);

	if (self.requestCompletionBlock != nil) {
		self.requestCompletionBlock(self.parsedData, self.error);
	}
}

@end
