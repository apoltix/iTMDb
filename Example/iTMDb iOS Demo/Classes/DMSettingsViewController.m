//
//  DMSettingsViewController.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 16/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DMSettingsViewController.h"
#import "DMSettingsTextTableViewCell.h"
#import "DMSettingsManager.h"

NSString * const TextFieldCellIdentifier = @"TextFieldCell";
NSString * const SwitchCellIdentifier = @"SwitchCell";

@implementation DMSettingsViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)];
}

#pragma mark -

- (void)close:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DMSettingsTextTableViewCell *cell = (DMSettingsTextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:TextFieldCellIdentifier forIndexPath:indexPath];

	DMSetting setting = (DMSetting)indexPath.row;
	cell.setting = setting;

	return cell;
}

@end
