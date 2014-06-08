//
//  TMDBImageView.h
//  iTMDbTest
//
//  Created by Christian Rasmussen on 25/09/13.
//  Copyright (c) 2013 Devify. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TMDBImageView : NSView

@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, strong) NSImage *image;

@end