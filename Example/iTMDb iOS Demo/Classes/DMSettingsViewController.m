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
NSString * const NumberCellIdentifier = @"NumberCell";

@interface DMSettingsViewController ()

@end

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
	return [DMSettingsManager sharedManager].settings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DMSettingsItem *settingsItem = (DMSettingsItem *)[DMSettingsManager sharedManager].settings[indexPath.row];

	DMSettingsTableViewCell *cell = nil;

	switch (settingsItem.type) {
		case DMSettingsItemTypeString: {
			cell = (DMSettingsTextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:TextFieldCellIdentifier forIndexPath:indexPath];
		} break;
		case DMSettingsItemTypeBool: {
			cell = (DMSettingsTextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:SwitchCellIdentifier forIndexPath:indexPath];
		} break;
		case DMSettingsItemTypeInteger: {
			cell = (DMSettingsTextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NumberCellIdentifier forIndexPath:indexPath];
		} break;
		case DMSettingsItemTypeNone: {
		} break;
	}

	cell.settingsItem = settingsItem;

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	DMSettingsItem *settingsItem = (DMSettingsItem *)[DMSettingsManager sharedManager].settings[indexPath.row];

	switch (settingsItem.type) {
		case DMSettingsItemTypeString:  return 64.0;
		case DMSettingsItemTypeBool:    return 47.0;
		case DMSettingsItemTypeInteger: return 64.0;
		case DMSettingsItemTypeNone:    break;
	}

	return 44.0;
}

@end
