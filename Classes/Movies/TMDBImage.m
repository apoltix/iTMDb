//
//  TMDBImage.m
//  iTMDb
//
//  Created by Christian Rasmussen on 07/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import "TMDBImage.h"

@interface TMDBImage ()

- (NSMutableDictionary *)imageDataForSize:(TMDBImageSize)size;

@end

@implementation TMDBImage

@synthesize id=_id, type=_type;//, urls=_urls;
@dynamic sizes;

+ (TMDBImage *)imageWithId:(NSString *)anID ofType:(TMDBImageType)type
{
	return [[TMDBImage alloc] initWithId:anID ofType:type];
}

- (TMDBImage *)initWithId:(NSString *)anID ofType:(TMDBImageType)type
{
	_id   = anID;
	_type = type;

	_data  = [NSMutableDictionary dictionaryWithCapacity:1];

	return self;
}

#pragma mark -
- (NSMutableDictionary *)imageDataForSize:(TMDBImageSize)size
{
	return [_data objectForKey:[NSNumber numberWithInt:size]];
}

#pragma mark URLs
- (NSURL *)urlForSize:(TMDBImageSize)size
{
	return [[self imageDataForSize:size] objectForKey:@"url"];
}

- (void)setURL:(NSURL *)url forSize:(TMDBImageSize)size
{
	NSMutableDictionary *imageData = [self imageDataForSize:size];
	if (!imageData)
	{
		imageData = [NSMutableDictionary dictionaryWithCapacity:3];
		[imageData setObject:[NSNumber numberWithFloat:0.0f] forKey:@"width"];
		[imageData setObject:[NSNumber numberWithFloat:0.0f] forKey:@"height"];

		[_data setObject:imageData forKey:[NSNumber numberWithInt:size]];
	}

	[imageData setObject:url forKey:@"url"];
}

#pragma mark Sizes
- (CGSize)sizeForSize:(TMDBImageSize)size
{
	NSDictionary *imageData = [self imageDataForSize:size];
	if (!imageData)
		return CGSizeZero;
	return CGSizeMake((CGFloat)[[imageData objectForKey:@"width"] floatValue], (CGFloat)[[imageData objectForKey:@"height"] floatValue]);
}

- (TMDBImageSize)sizes
{
	TMDBImageSize theSizes = 0;
	for (NSNumber *aSize in [_data allKeys])
		theSizes = theSizes | [aSize intValue];
	return theSizes;
}

- (NSUInteger)sizeCount
{
	return [_data count];
}

#pragma mark -
- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %@ (%i sizes)>", [self class], _id, [_data count], nil];
}

#pragma mark -

@end