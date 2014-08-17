//
//  DMSettingsTextTableViewCell.h
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 16/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "DMSettingsTableViewCell.h"

@interface DMSettingsTextTableViewCell : DMSettingsTableViewCell <UITextFieldDelegate>

@property (nonatomic, weak, readonly) UITextField *textField;

@end
