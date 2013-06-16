//
//  TMDBError.h
//  iTMDb
//
//  Created by Christian Rasmussen on 16/06/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const TMDBErrorDomain;

typedef NS_ENUM(NSUInteger, TMDBErrorCode) {
	TMDBErrorCodeReceivedInvalidData = 1001
};