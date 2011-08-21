//
//  TMDBRequest.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import "TMDBRequest.h"

#import "JSON.h"

@implementation TMDBRequest

@synthesize data, delegate, completionBlock;

+ (TMDBRequest *)requestWithURL:(NSURL *)url delegate:(id <TMDBRequestDelegate>)aDelegate
{
	TMDBRequest *vlreq = [[[TMDBRequest alloc] init] autorelease];

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url
													   cachePolicy:NSURLRequestReloadIgnoringCacheData
												   timeoutInterval:30.0];

	NSURLConnection *conn = [NSURLConnection connectionWithRequest:req delegate:vlreq];
	
	if (conn)
	{
		vlreq.data = [NSMutableData data];
		vlreq.delegate = aDelegate;
		return vlreq;
	}
	return nil;
}

+ (TMDBRequest *)requestWithURL:(NSURL *)url completionBlock:(void (^)(NSDictionary *parsedData))block
{
	TMDBRequest *req = [TMDBRequest requestWithURL:url delegate:nil];
	req.completionBlock = block;
	return req;
}

#pragma mark -
- (NSDictionary *)parsedData
{
	NSString *parsedDataString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
	NSDictionary *jsonData = (NSDictionary *)[parsedDataString JSONValue];
	//if (!jsonData)
	//	NSLog(@"parsedDataString = %@", parsedDataString);

	[parsedDataString release];

	return jsonData;
}

#pragma mark -
#pragma mark NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)thedata
{
	[self.data appendData:thedata];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.data = nil;

	if (delegate)
		[delegate request:self didFinishLoading:error];
	else if (completionBlock)
		completionBlock(nil);
	//else
	//	NSLog(@"TMDBRequest did fail with error: %@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (delegate)
		[delegate request:self didFinishLoading:nil];
	else if (completionBlock)
		completionBlock([self parsedData]);
	//else
	//	NSLog(@"TMDBRequest: Neither a delegate nor a block was set.");

	self.data = nil;
}

#pragma mark -
- (void)dealloc
{
	self.data = nil;
	self.completionBlock = nil;

	[super dealloc];
}

@end