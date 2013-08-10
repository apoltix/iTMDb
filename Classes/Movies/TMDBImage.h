//
//  TMDBImage.h
//  iTMDb
//
//  Created by Christian Rasmussen on 07/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TMDBImageType) {
	TMDBImageTypePoster,
	TMDBImageTypeBackdrop
};

typedef NS_ENUM(NSUInteger, TMDBImageSize) {
	TMDBImageSizeOriginal = 1 << 1,
	TMDBImageSizeMid      = 1 << 2,
	TMDBImageSizeCover    = 1 << 3,
	TMDBImageSizeThumb    = 1 << 4
};

/**
 * A `TMDBImage` object represents an image in one-to-many sizes.
 */
@interface TMDBImage : NSObject

@property (nonatomic, readonly) TMDBImageType type;
@property (nonatomic, readonly) TMDBImageSize sizes;
@property (nonatomic, copy, readonly) NSString *id;

+ (TMDBImage *)imageWithId:(NSString *)anID ofType:(TMDBImageType)type;

- (TMDBImage *)initWithId:(NSString *)anID ofType:(TMDBImageType)type;

- (NSURL *)urlForSize:(TMDBImageSize)size;
- (void)setURL:(NSURL *)url forSize:(TMDBImageSize)size;

- (CGSize)sizeForSize:(TMDBImageSize)size;

- (NSUInteger)sizeCount;

@end