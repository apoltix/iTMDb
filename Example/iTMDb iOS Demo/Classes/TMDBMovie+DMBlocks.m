//
//  TMDBMovie+DMBlocks.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 17/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "TMDBMovie+DMBlocks.h"
#import <objc/runtime.h>

NSUInteger const TMDBMovieDidFinishLoadingBlock;

@implementation TMDBMovie (DMBlocks)

- (void (^)(NSError *))didFinishLoadingBlock {
	return objc_getAssociatedObject(self, &TMDBMovieDidFinishLoadingBlock);
}

- (void)setDidFinishLoadingBlock:(void (^)(NSError *))block {
	objc_setAssociatedObject(self, &TMDBMovieDidFinishLoadingBlock, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
