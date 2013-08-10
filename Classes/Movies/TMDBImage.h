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
 * A `TMDBImage` object represents an image in one-to-many sizes.
 */
@interface TMDBImage : NSObject

@property (nonatomic, strong, readonly) TMDB *context;

@property (nonatomic, readonly) TMDBImageType type;
@property (nonatomic, readonly) TMDBSize originalSize;
@property (nonatomic, readonly) float aspectRatio; // This is actually unnecessary
@property (nonatomic, copy, readonly) NSString *iso639_1;

@property (nonatomic, readonly) float voteAverage;
@property (nonatomic, readonly) NSUInteger voteCount;

+ (NSArray *)imageArrayWithRawImageDictionaries:(NSArray *)rawImages ofType:(TMDBImageType)aType context:(TMDB *)context;

- (instancetype)initWithDictionary:(NSDictionary *)rawImageData type:(TMDBImageType)type context:(TMDB *)context;

- (NSURL *)urlForSize:(NSString *)size;

- (TMDBSize)sizeForSize:(NSString *)size UNAVAILABLE_ATTRIBUTE; // Not yet updated

@end

@interface TMDBImage (UnavailableMethods)

@property (nonatomic, copy, readonly) NSString *id UNAVAILABLE_ATTRIBUTE;

+ (TMDBImage *)imageWithId:(NSString *)anID ofType:(TMDBImageType)type UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithID:(NSString *)anID ofType:(TMDBImageType)type UNAVAILABLE_ATTRIBUTE;

@end