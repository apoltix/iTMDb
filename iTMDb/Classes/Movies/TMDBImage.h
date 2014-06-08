//
//  TMDBImage.h
//  iTMDb
//
//  Created by Christian Rasmussen on 07/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMDB;

typedef NS_ENUM(NSUInteger, TMDBImageType) {
	TMDBImageTypePoster,
	TMDBImageTypeBackdrop
};

// Don't use CGRect/NSRect to avoid dependency to Core Graphics.
typedef struct {
	float width;
	float height;
} TMDBSize;

/**
 * 
 */
typedef NS_ENUM(NSUInteger, TMDBImageSize) {
	TMDBImageSizeOriginal,
	TMDBImageSizeWidth,
	TMDBImageSizeHeight
};

/**
 * A `TMDBImage` object represents an image in one-to-many sizes.
 */
@interface TMDBImage : NSObject

@property (nonatomic, strong, readonly) TMDB *context;

@property (nonatomic, readonly) TMDBImageType type;
@property (nonatomic, readonly) TMDBSize originalSize;
@property (nonatomic, readonly) float aspectRatio; // This is actually unnecessary
@property (nonatomic, copy, readonly) NSString *iso639_1; // Two-letter language code

@property (nonatomic, readonly) float voteAverage;
@property (nonatomic, readonly) NSUInteger voteCount;

/** @name Creating `TMDBImage` instances */

+ (NSArray *)imageArrayWithRawImageDictionaries:(NSArray *)rawImages ofType:(TMDBImageType)aType context:(TMDB *)context;

- (instancetype)initWithDictionary:(NSDictionary *)rawImageData type:(TMDBImageType)type context:(TMDB *)context NS_DESIGNATED_INITIALIZER;

/** @name Getting URLs */

+ (NSURL *)urlForSize:(NSString *)size imagePath:(NSString *)imagePath context:(TMDB *)context;
- (NSURL *)urlForSize:(NSString *)size;

/** @name Getting Sizes */

/**
 * Returns the width or height of an image size string. If no size is explicitly
 * specified, such as the `original` size, `-1` is returned. The dimension, i.e.
 * either width or height (or original) is put in the `outImageSize` parameter.
 */
+ (float)sizeFromString:(NSString *)s imageSize:(TMDBImageSize *)outImageSize;

/**
 * Returns the size from `sizes` that closest matches the specified `size`.
 *
 * The size equal to or larger than the specified `size`, or if none such exist
 * the size that matches the closest, is returned.
 *
 * @param size The size in pixels that should be returned in string form.
 * @param sizes An array of `NSString`s that should be enumerated.
 * @param dimension The dimension (width, height or original) that should be
 * returned.
 * @return An `NSString` representing the `size` in the specified `dimension`,
 * or nil if no such exist.
 */
+ (NSString *)sizeClosestMatchingSize:(float)size inSizes:(NSArray *)sizes dimension:(TMDBImageSize)dimension;

- (TMDBSize)sizeForSize:(NSString *)size UNAVAILABLE_ATTRIBUTE; // Not yet updated

@end

@interface TMDBImage (UnavailableMethods)

@property (nonatomic, copy, readonly) NSString *id UNAVAILABLE_ATTRIBUTE;

+ (TMDBImage *)imageWithId:(NSString *)anID ofType:(TMDBImageType)type UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithID:(NSString *)anID ofType:(TMDBImageType)type UNAVAILABLE_ATTRIBUTE;

@end