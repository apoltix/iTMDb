//
//  TMDBImageViewItem.m
//  iTMDbTest
//
//  Created by Christian Rasmussen on 25/09/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

#import "TMDBImageViewItem.h"

#import "TMDBImageView.h"
#import <iTMDb/iTMDB.h>

@implementation TMDBImageViewItem

//- (id)copyWithZone:(NSZone *)zone
//{
//	TMDBImageViewItem *copy = [super copyWithZone:zone];
//
//	return copy;
//}

- (TMDBImageView *)tmdbImageView
{
	return (TMDBImageView *)self.view;
}

- (void)setSelected:(BOOL)selected
{
	[super setSelected:selected];

	self.tmdbImageView.selected = selected;
	[self.view setNeedsDisplay:YES];
}

- (void)setRepresentedObject:(TMDBImage *)image
{
	[super setRepresentedObject:image];

	self.textField.stringValue = [image description] ? : @"";

	if (image != nil)
	{
		TMDBConfiguration *config = image.context.configuration;
		NSString *imageSize = [TMDBImage sizeClosestMatchingSize:self.view.frame.size.width inSizes:config.imagesPosterSizes dimension:TMDBImageSizeWidth];
		NSURL *imageURL = [image urlForSize:imageSize];

		if (imageURL != nil)
		{
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
				dispatch_async(dispatch_get_main_queue(), ^{
					self.tmdbImageView.image = image;
				});
			});
		}
		else
			self.tmdbImageView.image = nil;
	}
	else
		self.tmdbImageView.image = nil;
}

@end