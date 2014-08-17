//
//  DMAppDelegate.h
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 09/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iTMDb/iTMDb.h>

@interface DMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) TMDB *tmdb;

@end
