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

static NSCache *imageCache;

@implementation TMDBImageViewItem

+ (void)initialize
{
	imageCache = [[NSCache alloc] init];
}

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

	if (image != nil) {
		TMDBConfiguration *config = [TMDB sharedInstance].configuration;

		NSString *imageSize = [TMDBImage sizeClosestMatchingSize:self.view.frame.size.width
														 inSizes:config.imagesPosterSizes
													   dimension:TMDBImageSizeWidth];

		NSURL *imageURL = [image urlForSize:imageSize];

		NSImage *cachedImage = [imageCache objectForKey:imageURL];

		if (cachedImage != nil) {
			self.tmdbImageView.image = cachedImage;
		}
		else if (imageURL != nil) {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				// Never download images this way. Only done this way to avoid dependencies
				NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
				dispatch_async(dispatch_get_main_queue(), ^{
					if (image != nil) {
						self.tmdbImageView.image = image;
						[imageCache setObject:image forKey:imageURL];
					}
					else {
						self.tmdbImageView.image = [NSImage imageNamed:NSImageNameCaution];
					}
				});
			});
		}
		else {
			self.tmdbImageView.image = [NSImage imageNamed:NSImageNameCaution];
		}
	}
	else {
		self.tmdbImageView.image = [NSImage imageNamed:NSImageNameCaution];
	}
}

@end