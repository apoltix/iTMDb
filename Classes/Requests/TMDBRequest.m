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

@synthesize data, delegate;

+ (TMDBRequest *)requestWithURL:(NSURL *)url delegate:(id <TMDBRequestDelegate>)aDelegate
{
	TMDBRequest *vlreq = [TMDBRequest alloc];

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url
													   cachePolicy:NSURLRequestReloadIgnoringCacheData
												   timeoutInterval:30.0];

	//UIDevice *device = [UIDevice currentDevice];

	//[req setValue:[NSString stringWithFormat:@"%@ %@",API_CLIENT_NAME,API_CLIENT_VERSION] forHTTPHeaderField:@"X-Client"];
	//[req setValue:device.uniqueIdentifier forHTTPHeaderField:@"X-Device-UDID"];
	//[req setValue:device.name forHTTPHeaderField:@"X-Device-Name"];
	//[req setValue:device.model forHTTPHeaderField:@"X-Device-Model"]; // TODO: Use Erica Sadun's UIDevice extension to determine exact model
	//[req setValue:device.systemName forHTTPHeaderField:@"X-Device-OS-Name"];
	//[req setValue:device.systemVersion forHTTPHeaderField:@"X-Device-OS-Version"];

	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:vlreq];
	
	if (conn)
	{
		vlreq.data = [[NSMutableData data] retain];
		vlreq.delegate = aDelegate;
		return vlreq;
	}
	else
	{
		[vlreq release];
	}

	return nil;
}

#pragma mark -
- (NSDictionary *)parsedData
{
	NSString *parsedDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary *jsonData = (NSDictionary *)[parsedDataString JSONValue];
	if (!jsonData)
		NSLog(@"parsedDataString = %@", parsedDataString);
	
	[parsedDataString release];
	
	return jsonData;
}

#pragma mark -
#pragma mark NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)thedata
{
	[data appendData:thedata];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	//printf("NSURLConnection did send %i bytes (%i total) in body data, with %i in total (estimate).\n", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
	//if (delegate && [(NSObject *)delegate respondsToSelector:@selector(request:didSendPostDataWithProgress:)])
	//	[delegate request:self didSendPostDataWithProgress:(float)totalBytesWritten * 100.0 / (float)totalBytesExpectedToWrite];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"TMDBRequest did fail with error: %@", error);
	[delegate request:self didFinishLoading:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [connection release];
    [data release]; // Release the hold that was made with the connection

	[delegate request:self didFinishLoading:nil];
}

#pragma mark -
#pragma mark Keyed Archiver Delegate
- (void)archiverDidFinish:(NSKeyedArchiver *)archiver
{
	printf("Keyed archiver did finish %s.\n", [[archiver description] UTF8String]);
}

@end