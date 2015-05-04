//
//  DetailViewController.h
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 09/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

@import UIKit;

@class TMDBMovie;

@interface DetailViewController : UIViewController

@property (nonatomic, strong) TMDBMovie *movie;
@property (nonatomic, weak) IBOutlet UILabel *detailDescriptionLabel;

@end
