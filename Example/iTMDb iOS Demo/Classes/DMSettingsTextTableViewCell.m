//
//  DMSettingsTextTableViewCell.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 16/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DMSettingsTextTableViewCell.h"

@interface DMSettingsTextTableViewCell () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextField *textField;

@end

@implementation DMSettingsTextTableViewCell

- (void)prepareForReuse {
	[super prepareForReuse];

	self.setting = DMSettingNone;
}

- (UILabel *)textLabel {
	return self.titleLabel;
}

- (void)setSetting:(DMSetting)setting {
	_setting = setting;

	if (setting == DMSettingNone) {
		self.textField.text = @"";
		return;
	}

	self.textLabel.text = [[DMSettingsManager sharedManager] localizedStringForSetting:setting];
	self.textField.text = [[DMSettingsManager sharedManager] valueForSetting:setting];
}

#pragma mark - UITextFieldDelegate 

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[[DMSettingsManager sharedManager] setValue:textField.text forSetting:self.setting];
}

@end
