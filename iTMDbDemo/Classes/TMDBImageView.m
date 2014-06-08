//
//  TMDBImageView.m
//  iTMDbTest
//
//  Created by Christian Rasmussen on 25/09/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

#import "TMDBImageView.h"

@implementation TMDBImageView

- (void)setImage:(NSImage *)image
{
	_image = image;

	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[self.image drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];

	if (self.selected)
	{
		CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
		CGContextSetRGBFillColor(ctx, 76.0/255.0, 178.0/255.0, 62.0/255.0, 0.35);
		CGContextFillRect(ctx, dirtyRect);
	}
}

@end