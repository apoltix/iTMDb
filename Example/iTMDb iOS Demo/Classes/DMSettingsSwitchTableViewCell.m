//
//  DMSettingsSwitchTableViewCell.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 17/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DMSettingsSwitchTableViewCell.h"

@interface DMSettingsSwitchTableViewCell ()

@property (nonatomic, weak) IBOutlet UISwitch *toggle;

@end

@implementation DMSettingsSwitchTableViewCell

- (void)setSettingsItem:(DMSettingsItem *)item {
	[super setSettingsItem:item];

	self.toggle.on = [(NSNumber *)self.settingsItem.value boolValue];
}

- (IBAction)toggleValueChanged:(UISwitch *)toggle {
	self.settingsItem.value = @(toggle.on);
}

@end
