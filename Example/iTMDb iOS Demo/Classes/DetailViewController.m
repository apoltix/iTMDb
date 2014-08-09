//
//  DetailViewController.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 09/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)setDetailItem:(id)newDetailItem {
	if (_detailItem == newDetailItem) {
		return;
	}

	_detailItem = newDetailItem;

	[self configureView];
}

- (void)configureView {
	if (self.detailItem) {
		self.detailDescriptionLabel.text = [self.detailItem description];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self configureView];
}

@end
