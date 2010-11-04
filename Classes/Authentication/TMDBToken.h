//
//  TMDBToken.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TMDB;

//#import "TMDB.h"
#import "TMDBRequest.h"
#import "TMDBRequestDelegate.h"

@interface TMDBToken : NSObject {
	TMDBRequest *_request;
}

+ (TMDBToken *)tokenWithContext:(TMDB *)context delegate:(id <TMDBRequestDelegate>)delegate;

- (id)initWithContext:(TMDB *)context delegate:(id <TMDBRequestDelegate>)delegate;

@end