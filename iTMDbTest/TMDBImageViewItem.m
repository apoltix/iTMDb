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

- (id)copyWithZone:(NSZone *)zone
{
	TMDBImageViewItem *copy = [super copyWithZone:zone];

	NSArray *subviews = [copy.view subviews];
	copy.imageView = subviews[0];

	return copy;
}

- (void)setRepresentedObject:(TMDBImage *)image
{
	[super setRepresentedObject:image];

	self.textField.stringValue = [image description] ? : @"";

	TMDBConfiguration *config = image.context.configuration;
	NSURL *imageURL = [image urlForSize:config.imagesPosterSizes[0]];

	if (imageURL != nil)
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
			dispatch_async(dispatch_get_main_queue(), ^{
				self.imageView.image = image;
			});
		});
	}
	else
		self.imageView.image = nil;
}

@end