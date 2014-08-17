//
//  DMSettingsNumberTableViewCell.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 17/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DMSettingsNumberTableViewCell.h"
#import "NSString+DMStringContainsOnlyNumbers.h"

@interface DMSettingsNumberTableViewCell ()

@property (nonatomic, weak) IBOutlet UIStepper *stepper;

@end

@implementation DMSettingsNumberTableViewCell

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return [string dm_containsOnlyNumbers];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (![textField.text dm_containsOnlyNumbers]) {
		self.textField.text = (NSString *)self.settingsItem.value;
		return;
	}

	[super textFieldDidEndEditing:textField];
}

#pragma mark -

- (IBAction)stepperValueChanged:(UIStepper *)sender {
	long long newValue = [(NSNumber *)self.settingsItem.value longLongValue] + (NSInteger)sender.value;

	self.textField.text = [NSString stringWithFormat:@"%@", @(newValue)];
	sender.value = 0.0;

	[self saveValue];
}

@end
