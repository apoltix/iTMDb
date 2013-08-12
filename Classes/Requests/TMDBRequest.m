//
//  TMDBRequest.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import "TMDBRequest.h"

@implementation TMDBRequest {
@private
	NSMutableData *_data;
	id _parsedData;
	TMDBRequestCompletionBlock _completionBlock;
}

+ (instancetype)requestWithURL:(NSURL *)url delegate:(id<TMDBRequestDelegate>)aDelegate
{
	return [[TMDBRequest alloc] initWithURL:url delegate:aDelegate];
}

+ (instancetype)requestWithURL:(NSURL *)url completionBlock:(TMDBRequestCompletionBlock)block
{
	return [[TMDBRequest alloc] initWithURL:url completionBlock:block];
}

- (instancetype)initWithURL:(NSURL *)url delegate:(id<TMDBRequestDelegate>)delegate
{
	if (!(self = [super init]))
		return nil;

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];

	if ([NSURLConnection connectionWithRequest:req delegate:self])
	{
		_data = [NSMutableData data];
		_delegate = delegate;
	}

	return self;
}

- (instancetype)initWithURL:(NSURL *)url completionBlock:(TMDBRequestCompletionBlock)block
{
	if (!(self = [super init]))
		return nil;

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];

	if ([NSURLConnection connectionWithRequest:req delegate:self])
	{
		_data = [NSMutableData data];
		_completionBlock = [block copy];
	}

	return self;
}

#pragma mark -

- (id)parsedData
{
	if (_parsedData)
		return _parsedData;

	NSError *error = nil;
	id parsedData = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
	if (error)
		TMDBLog(@"iTMDb: Error parsing JSON data: %@", error);

	_parsedData = parsedData;

	return parsedData;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	_parsedData = nil;
	[_data setLength:0];
	_response = [response copy];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)thedata
{
	[_data appendData:thedata];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	_data = nil;
	_parsedData = nil;

	if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFinishLoading:)])
		[self.delegate request:self didFinishLoading:error];

	if (self.completionBlock)
		self.completionBlock(nil);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFinishLoading:)])
		[self.delegate request:self didFinishLoading:nil];

	if (self.completionBlock)
		self.completionBlock([self parsedData]);

	_data = nil;
}

@end