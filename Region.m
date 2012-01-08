//
//  Region.m
//  Sudoku
//
//  Created by Mike Barriault on 12-01-07.
//  Copyright (c) 2012 Memorial University. All rights reserved.
//

#import "Region.h"

@implementation Region

@synthesize cells = _cells;

+(id) region {
    return [Region regionWithValues:9, 0, 0, 0, 0, 0, 0, 0, 0, 0];
}

-(id) init {
    return [self initWithValues:9, 0, 0, 0, 0, 0, 0, 0, 0, 0];
}

-(id) initWithCells:(Cell *)cell, ... {
    if ( self = [super init] ) {
        NSMutableArray* cells = [NSMutableArray arrayWithCapacity:9];
        va_list vl;
        va_start(vl, cell);
        do {
            [cells addObject:cell];
        } while ( (cell = va_arg(vl, Cell*)) );
        _cells = [NSArray arrayWithArray:cells];
    }
    return self;
}

+(id) regionWithValues:(int)count, ... {
    va_list vl;
    va_start(vl, count);
    return [[Region alloc] initWithValueList:vl ofCount:count];
}

-(id) initWithValues:(int)count, ... {
    va_list vl;
    va_start(vl, count);
    return [self initWithValueList:vl ofCount:count];
}

-(id) initWithValueList:(va_list)vl ofCount:(int)count {
    if ( self = [super init] ) {
        NSMutableArray* cells = [NSMutableArray arrayWithCapacity:count];
        for ( int i=0; i<count; i++ ) {
            [cells addObject:[Cell cellWithValue:va_arg(vl, char)]];
        }
        _cells = [NSArray arrayWithArray:cells];
        va_end(vl);
    }
    return self;
}

+(id) regionWithCellArray:(NSArray *)cells {
    return [[Region alloc] initWithCellArray:cells];
}

-(id) initWithCellArray:(NSArray *)cells {
    if ( self = [super init] ) {
        _cells = cells;
    }
    return self;
}

-(char) conflict {
    NSArray* sortedCells = [self.cells sortedArrayUsingComparator:^(Cell* a, Cell* b) { if ( a.value < b.value ) return (NSComparisonResult)NSOrderedAscending; else if ( a.value > b.value ) return (NSComparisonResult)NSOrderedDescending; else return NSOrderedSame; } ];
    char old = -1;
    for ( Cell* cell in sortedCells ) {
        if ( [cell.value charValue] == old )
            return conflict_found;
        else if ( [cell.value charValue] == 0 )
            continue;
        else
            old = [cell.value charValue];
    }
    return conflict_free;
}

-(NSSet*) possibleForCell:(Cell *)cell andDim:(int)dim {
    if ( [cell.value charValue] != 0 )
        return [NSSet set];
    else {
        NSMutableSet* possibles = [NSMutableSet set];
        int rsize = pow(dim,2);
        char values[rsize];
        for ( int i=0; i<rsize; i++ )
            values[i] = i+1;
        for ( Cell* cell in self.cells )
            values[ [cell.value intValue]-1 ] = 0;
        for ( int i=0; i<rsize; i++ )
            if ( values[i] != 0 )
                [possibles addObject:[NSNumber numberWithChar:values[i]]];
        return possibles;
    }
}

-(NSString*) description {
    NSString* description = @"";
    for ( Cell* cell in self.cells )
        description = [description stringByAppendingFormat:@"%@ ", [cell description]];
    return description;
}

@end
