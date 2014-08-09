//
//  TMDBCollectionView.m
//  iTMDbDemo
//
//  Created by Christian Rasmussen on 11/06/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "TMDBCollectionView.h"
#import "TMDBImageViewItem.h"
#import "TMDBImageView.h"

@implementation TMDBCollectionView {
@private
	NSNib *_itemNib;
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	_itemNib = [[NSNib alloc] initWithNibNamed:@"TMDBImageViewItem" bundle:nil];

	self.minItemSize = NSMakeSize(60, 90);
	self.maxItemSize = self.minItemSize;
}

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object
{
	TMDBImageViewItem *item = [[TMDBImageViewItem alloc] initWithNibName:nil bundle:nil];

	NSArray *items = nil;
	if (![_itemNib instantiateWithOwner:item topLevelObjects:&items]) {
		NSLog(@"Failed to instantiate nib.");
	}

	__block TMDBImageView *view = nil;

	[items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[TMDBImageView class]]) {
			view = obj;
			*stop = YES;
		}
	}];

	item.view = view;
	item.representedObject = object;

	return item;
}

@end
