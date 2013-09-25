//
//  TMDBImageViewItem.m
//  iTMDbTest
//
//  Created by Christian Rasmussen on 25/09/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

#import "TMDBImageViewItem.h"

#import "TMDBImageView.h"

@implementation TMDBImageViewItem

- (id)copyWithZone:(NSZone *)zone
{
	TMDBImageViewItem *copy = [super copyWithZone:zone];

	NSArray *subviews = [copy.view subviews];
	copy.imageView = subviews[0];

	return copy;
}

- (void)setRepresentedObject:(id)representedObject
{
	[super setRepresentedObject:representedObject];

	self.textField.stringValue = [representedObject description] ? : @"";
}

@end