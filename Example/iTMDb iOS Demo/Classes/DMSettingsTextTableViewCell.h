//
//  DMSettingsTextTableViewCell.h
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 16/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMSettingsManager.h"

@interface DMSettingsTextTableViewCell : UITableViewCell

@property (nonatomic) DMSetting setting;
@property (nonatomic, weak, readonly) UITextField *textField;

@end
