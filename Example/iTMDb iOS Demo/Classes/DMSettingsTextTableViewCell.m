//
//  DMSettingsTextTableViewCell.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 16/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DMSettingsTextTableViewCell.h"

@interface DMSettingsTextTableViewCell ()

@property (nonatomic, weak) IBOutlet UITextField *textField;

@end

@implementation DMSettingsTextTableViewCell

- (void)setSettingsItem:(DMSettingsItem *)item {
	[super setSettingsItem:item];

	self.textField.text = [(id)self.settingsItem.value description];
}

#pragma mark - UITextFieldDelegate 

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.settingsItem.value = textField.text;
}

@end
