//
//  TMDBHelpers.h
//  iTMDb
//
//  Created by Christian Rasmussen on 10/08/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

#import <Foundation/Foundation.h>

id TMDB_ObjectOfClassOrNil(id objectOrNil, Class expectedClass);
NSString *TMDB_NSStringOrNil(NSString *stringOrNil);
NSNumber *TMDB_NSNumberOrNil(NSNumber *numberOrNil);
NSURL *TMDB_NSURLOrNilFromStringOrNil(NSString *urlString);
NSArray *TMDB_NSArrayOrNil(NSArray *arrayOrNil);