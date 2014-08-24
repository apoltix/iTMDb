//
//  TMDBRequest.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright (c) 2010 Devify. All rights reserved.
//

#import "TMDBRequest.h"

@implementation TMDBRequest {
@private
	NSMutableData *_data;
	id _parsedData;
	TMDBRequestCompletionBlock _completionBlock;
}

+ (instancetype)requestWithURL:(NSURL *)url completionBlock:(TMDBRequestCompletionBlock)block {
	__block TMDBRequest *request = [[TMDBRequest alloc] initWithURL:url completionBlock:^(id parsedData, NSError *error) {
		if (block != nil) {
			block(parsedData, error);
		}
		request = nil;
	}];
	return request;
}

- (instancetype)initWithURL:(NSURL *)url completionBlock:(TMDBRequestCompletionBlock)block {
	if (!(self = [super init])) {
		return nil;
	}

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];

	if ([NSURLConnection connectionWithRequest:req delegate:self]) {
		_data = [NSMutableData data];
		_completionBlock = [block copy];
	}

	return self;
}

#pragma mark -

- (id)parsedData {
	if (_parsedData != nil) {
		return _parsedData;
	}

	NSError *error = nil;
	id parsedData = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
	if (error != nil) {
		TMDBLog(@"iTMDb: Error parsing JSON data: %@", error);
	}

	_parsedData = parsedData;

	return parsedData;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	_parsedData = nil;
	_data.length = 0;
	_response = [response copy];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)thedata {
	[_data appendData:thedata];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	_data = nil;
	_parsedData = nil;

	if (self.completionBlock != nil) {
		self.completionBlock(nil, error);
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (self.completionBlock != nil) {
		self.completionBlock([self parsedData], nil);
	}

	_data = nil;
}

@end
