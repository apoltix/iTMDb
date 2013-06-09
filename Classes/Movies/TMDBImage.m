//
//  TMDBImage.m
//  iTMDb
//
//  Created by Christian Rasmussen on 07/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import "TMDBImage.h"

@implementation TMDBImage {
@private
	NSMutableDictionary *_data;
}

+ (TMDBImage *)imageWithId:(NSString *)anID ofType:(TMDBImageType)type
{
	return [[TMDBImage alloc] initWithId:anID ofType:type];
}

- (TMDBImage *)initWithId:(NSString *)anID ofType:(TMDBImageType)type
{
	if (!(self = [super init]))
		return nil;

	_id   = anID;
	_type = type;

	_data  = [NSMutableDictionary dictionaryWithCapacity:1];

	return self;
}

#pragma mark -

- (NSMutableDictionary *)imageDataForSize:(TMDBImageSize)size
{
	return _data[@(size)];
}

#pragma mark - URLs

- (NSURL *)urlForSize:(TMDBImageSize)size
{
	return [self imageDataForSize:size][@"url"];
}

- (void)setURL:(NSURL *)url forSize:(TMDBImageSize)size
{
	NSMutableDictionary *imageData = [self imageDataForSize:size];
	if (!imageData)
	{
		imageData = [NSMutableDictionary dictionaryWithCapacity:3];
		imageData[@"width"] = @0;
		imageData[@"height"] = @0;

		_data[@(size)] = imageData;
	}

	imageData[@"url"] = url;
}

#pragma mark - Sizes

- (CGSize)sizeForSize:(TMDBImageSize)size
{
	NSDictionary *imageData = [self imageDataForSize:size];
	if (!imageData)
		return CGSizeZero;
	return CGSizeMake((CGFloat)[imageData[@"width"] floatValue], (CGFloat)[imageData[@"height"] floatValue]);
}

- (TMDBImageSize)sizes
{
	TMDBImageSize theSizes = 0;
	for (NSNumber *aSize in [_data allKeys])
		theSizes |= [aSize integerValue];
	return theSizes;
}

- (NSUInteger)sizeCount
{
	return [_data count];
}

#pragma mark -

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ %p: %@ (%li sizes)>", NSStringFromClass([self class]), self, _id, [_data count]];
}

@end