//
//  TMDBImage.m
//  iTMDb
//
//  Created by Christian Rasmussen on 07/11/10.
//  Copyright (c) 2010 Devify. All rights reserved.
//

#import "TMDBImage.h"
#import "TMDB.h"

@interface TMDBImage ()

@property (nonatomic, copy) NSString *filePath;

@end

@implementation TMDBImage

+ (NSArray *)imageArrayWithRawImageDictionaries:(NSArray *)rawImages ofType:(TMDBImageType)aType {
	NSMutableArray *images = [NSMutableArray array];

	for (NSDictionary *imageDict in rawImages) {
		TMDBImage *currentImage = [[TMDBImage alloc] initWithDictionary:imageDict type:aType];
		[images addObject:currentImage];
	}

	return images;
}

- (instancetype)initWithDictionary:(NSDictionary *)d type:(TMDBImageType)type {
	if (!(self = [super init])) {
		return nil;
	}

	_type = type;
	_filePath = [TMDB_NSStringOrNil(d[@"file_path"]) copy];
	_originalSize = CGSizeMake(TMDB_NSNumberOrNil(d[@"width"]).floatValue, TMDB_NSNumberOrNil(d[@"height"]).floatValue);
	_iso639_1 = TMDB_NSStringOrNil(d[@"iso_639_1"]);
	_voteAverage = TMDB_NSNumberOrNil(d[@"vote_average"]).floatValue;
	_voteCount = TMDB_NSNumberOrNil(d[@"vote_count"]).unsignedIntegerValue;

	return self;
}

#pragma mark - URLs

- (NSURL *)urlForSize:(NSString *)size {
	TMDB *context = [TMDB sharedInstance];
	return [[context.configuration.imagesBaseURL URLByAppendingPathComponent:size] URLByAppendingPathComponent:self.filePath];
}

#pragma mark - Sizes

+ (CGFloat)sizeFromString:(NSString *)s imageSize:(TMDBImageSize *)outImageSize {
	if (s.length == 0) {
		return -1.0f;
	}

	if ([s.lowercaseString isEqualToString:@"original"]) {
		if (outImageSize != nil) {
			*outImageSize = TMDBImageSizeOriginal;
		}

		return -1.0f;
	}

	if (outImageSize != nil) {
		NSString *prefix = [s substringToIndex:1].lowercaseString;

		if ([prefix isEqualToString:@"w"]) {
			*outImageSize = TMDBImageSizeWidth;
		}
		else if ([prefix isEqualToString:@"h"]) {
			*outImageSize = TMDBImageSizeHeight;
		}
	}

	NSString *size = [s substringFromIndex:1];
	return size.floatValue;
}

+ (NSString *)sizeClosestMatchingSize:(float)size inSizes:(NSArray *)sizes dimension:(TMDBImageSize)dimension {
	if (sizes.count == 0) {
		return nil;
	}

	CGFloat closestMatch = 0.0;
	NSString *closestMatchString = nil;

	for (NSString *s in sizes) {
		TMDBImageSize dim = TMDBImageSizeOriginal;
		CGFloat is = [TMDBImage sizeFromString:s imageSize:&dim];

		if (dim != dimension) {
			continue;
		}

		if (is < closestMatch || (closestMatch > size && is > size)) {
			continue;
		}

		closestMatch = is;
		closestMatchString = s;

		// Don't break, as the sizes might not be in order
	}

	if (closestMatchString == nil) {
		return sizes.firstObject;
	}

	return closestMatchString;
}

#pragma mark -

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@ %p: \"%@\", size %.0fx%.0f>", NSStringFromClass([self class]), self, self.filePath, self.originalSize.width, self.originalSize.height];
}

@end
