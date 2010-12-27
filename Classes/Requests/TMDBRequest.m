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
	TMDBRequest *vlreq = [[[TMDBRequest alloc] init] retain];

	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url
													   cachePolicy:NSURLRequestReloadIgnoringCacheData
												   timeoutInterval:30.0];

	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:vlreq];
	
	if (conn)
	{
		vlreq.data = [[NSMutableData data] retain];
		vlreq.delegate = aDelegate;
		return vlreq;
	}
	else
	{
		NSLog(@"TMDBRequest: Connection failed.\n");
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"TMDBRequest did fail with error: %@", error);
	[delegate request:self didFinishLoading:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	//printf("DID FINISH LOADING REQUEST\n");
	//[connection release];
	[data release]; // Release the hold that was made with the connection

	if (delegate)
		[delegate request:self didFinishLoading:nil];
	else
		printf("TMDBRequest: Delegate was not set.");
}

@end