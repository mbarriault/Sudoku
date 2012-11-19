//
//  NSSet+Random.m
//  Sudoku
//
//  Created by Mike Barriault on 12-01-08.
//  Copyright (c) 2012 Memorial University. All rights reserved.
//

#import "NSSet+Random.h"

@implementation NSSet (Random)

- (id) randomObject {
    NSArray * allObjects = [self allObjects];
    if ([allObjects count] == 0) return nil;
    return [allObjects objectAtIndex:(arc4random() % [allObjects count])];
}

@end
