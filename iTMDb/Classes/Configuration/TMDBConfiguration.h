//
//  TMDBConfiguration.h
//  iTMDb
//
//  Created by Christian Rasmussen on 09/08/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The TMDb configuration information includes information commonly needed 
 * in many API responses, such as base URLs. Instances of this class is
 * automatically created by the `TMDB` shared instance so you never need to
 * create an instance yourself.
 */
@interface TMDBConfiguration : NSObject

- (void)reload:(void (^)(NSError *error))completionBlock;

/** A value indicating if the configuration has been loaded yet. */
@property (nonatomic, readonly, getter=isLoaded) BOOL loaded;

@property (nonatomic, copy, readonly) NSURL *imagesBaseURL;
@property (nonatomic, copy, readonly) NSURL *imagesSecureBaseURL;

@property (nonatomic, copy, readonly) NSArray *imagesPosterSizes;
@property (nonatomic, copy, readonly) NSArray *imagesBackdropSizes;
@property (nonatomic, copy, readonly) NSArray *imagesProfileSizes;
@property (nonatomic, copy, readonly) NSArray *imagesLogoSizes;

@property (nonatomic, copy, readonly) NSArray *changeKeys;

@end
