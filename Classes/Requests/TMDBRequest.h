//
//  TMDBRequest.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMDBRequestDelegate.h"

@interface TMDBRequest : NSObject {
	NSMutableData *data;
	
	id<TMDBRequestDelegate> delegate;
}

@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, assign) id<TMDBRequestDelegate> delegate;

+ (TMDBRequest *)requestWithURL:(NSURL *)url delegate:(id<TMDBRequestDelegate>)delegate;

- (NSDictionary *)parsedData;

@end