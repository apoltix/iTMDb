//
//  TMDBImage.h
//  iTMDb
//
//  Created by Christian Rasmussen on 07/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	TMDBImageTypePoster,
	TMDBImageTypeBackdrop
} TMDBImageType;

typedef enum {
	TMDBImageSizeOriginal = 1 << 1,
	TMDBImageSizeMid      = 1 << 2,
	TMDBImageSizeCover    = 1 << 3,
	TMDBImageSizeThumb    = 1 << 4
} TMDBImageSize;

/**
 * A `TMDBImage` object represents an image in one-to-many sizes.
 */
@interface TMDBImage : NSObject {
	NSString *_id;
	TMDBImageType _type;
	NSMutableDictionary *_data;
}

@property (nonatomic, assign, readonly) TMDBImageType type;
@property (nonatomic, assign, readonly) TMDBImageSize sizes;
@property (nonatomic, strong, readonly) NSString *id;

+ (TMDBImage *)imageWithId:(NSString *)anID ofType:(TMDBImageType)type;

- (TMDBImage *)initWithId:(NSString *)anID ofType:(TMDBImageType)type;

- (NSURL *)urlForSize:(TMDBImageSize)size;
- (void)setURL:(NSURL *)url forSize:(TMDBImageSize)size;

- (CGSize)sizeForSize:(TMDBImageSize)size;

- (NSUInteger)sizeCount;

@end