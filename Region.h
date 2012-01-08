//
//  Region.h
//  Sudoku
//
//  Created by Mike Barriault on 12-01-07.
//  Copyright (c) 2012 Memorial University. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "Cell.h"

enum {
    conflict_found,
    conflict_free
};

@interface Region : NSObject

@property (strong, readonly) NSArray* cells;
+(id) region;
-(id) initWithCells:(Cell*)cell, ...;
+(id) regionWithValues:(int)count, ...;
-(id) initWithValues:(int)count, ...;
-(id) initWithValueList:(va_list)vl ofCount:(int)count;
+(id) regionWithCellArray:(NSArray*)cells;
-(id) initWithCellArray:(NSArray*)cells;
-(char) conflict;
-(NSSet*) possibleForDim:(int)dim;

@end
