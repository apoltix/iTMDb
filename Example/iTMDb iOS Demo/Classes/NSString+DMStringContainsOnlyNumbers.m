//
//  NSString+DMStringContainsOnlyNumbers.m
//  iTMDb iOS Demo
//
//  Created by Christian Rasmussen on 17/08/2014.
//  Copyright (c) 2014 Devify. All rights reserved.
//

#import "NSString+DMStringContainsOnlyNumbers.h"

NSCharacterSet *DMStringContainsOnlyNumbers_NoNumbers;

@implementation NSString (StringContainsOnlyNumbers)

+ (void)initialize {
	DMStringContainsOnlyNumbers_NoNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
}

- (BOOL)dm_containsOnlyNumbers
{
	return [self rangeOfCharacterFromSet:DMStringContainsOnlyNumbers_NoNumbers].location == NSNotFound;
}

@end
