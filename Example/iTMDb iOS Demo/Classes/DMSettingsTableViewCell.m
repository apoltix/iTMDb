//
//  DMSettingsTableViewCell.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 17/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DMSettingsTableViewCell.h"

@interface DMSettingsTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation DMSettingsTableViewCell

- (UILabel *)textLabel {
	return self.titleLabel;
}

- (void)prepareForReuse {
	[super prepareForReuse];

	self.settingsItem = nil;
}

- (void)setSettingsItem:(DMSettingsItem *)item {
	_settingsItem = item;

	if (item == nil) {
		return;
	}

	self.titleLabel.text = self.settingsItem.localizedName;
}

- (void)saveValue {
}

@end
