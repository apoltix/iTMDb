//
//  TMDBMovie+DMBlocks.h
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 17/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import <iTMDb/iTMDb.h>

@interface TMDBMovie (DMBlocks)

@property (nonatomic, copy) void (^didFinishLoadingBlock)(NSError *error);

@end
