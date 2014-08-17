//
//  DMSettingsTableViewCell.h
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 17/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMSettingsManager.h"

@interface DMSettingsTableViewCell : UITableViewCell

@property (nonatomic, weak, readonly) UILabel *titleLabel;

@property (nonatomic) DMSettingsItem *settingsItem;

@end
