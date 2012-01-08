//
//  Grid.m
//  Sudoku
//
//  Created by Mike Barriault on 12-01-07.
//  Copyright (c) 2012 Memorial University. All rights reserved.
//

#import "Grid.h"

@implementation Grid

@synthesize regions = _regions;
@synthesize dim = _dim;

+(id) grid {
    return [[Grid alloc] init];
}

-(id) init {
    return [self initWithDim:2];
}

+(id) gridWithDim:(int)dim {
    return [[Grid alloc] initWithDim:dim];
}

-(id) initWithDim:(int)dim {
    if ( self = [super init] ) {
        _dim = dim;
        int ncells = pow(dim,4);
        int nregions = 3*pow(dim,2);
        int rsize = pow(dim,2);
        NSMutableArray* cells = [NSMutableArray arrayWithCapacity:ncells];
        for ( int o=0; o<ncells; o++ )
            [cells addObject:[Cell cell]];
        // o = i*dim+j
        
        NSMutableArray* regions = [NSMutableArray arrayWithCapacity:nregions];
        
        for ( int i=0; i<rsize; i++ ) {
            NSArray* cellsInRegion = [cells objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i*rsize, rsize)]];
            [regions addObject:[Region regionWithCellArray:cellsInRegion]];
        }
        
        for ( int j=0; j<rsize; j++ ) {
            NSMutableIndexSet* indices = [NSMutableIndexSet indexSet];
            for ( int i=0; i<rsize; i++ )
                [indices addIndex:i*rsize+j];
            NSArray* cellsInRegion = [cells objectsAtIndexes:indices];
            [regions addObject:[Region regionWithCellArray:cellsInRegion]];
        }
        
        for ( int I=0; I<dim; I++ ) for ( int J=0; J<dim; J++ ) {
            NSMutableIndexSet* indices = [NSMutableIndexSet indexSet];
            for ( int i=dim*I; i<dim*(I+1); i++ ) for ( int j=dim*J; j<dim*(J+1); j++ )
                [indices addIndex:i*rsize+j];
            NSArray* cellsInRegion = [cells objectsAtIndexes:indices];
            [regions addObject:[Region regionWithCellArray:cellsInRegion]];
        }
        
        _regions = regions;
    }
    return self;
}

+(id) gridWithDim:(int)dim andRandoms:(float)givens {
    return [[Grid alloc] initWithDim:dim andRandoms:givens];
}

-(id) initWithDim:(int)dim andRandoms:(float)givens {
    if ( self = [self initWithDim:dim] ) {
        srand((unsigned int)time(NULL));
        int count = givens * pow(self.dim, 4);
        for ( int n=0; n<count; n++ ) {
            int r, c;
            Region* region;
            Cell* cell;
            do {
                r = rand() % (int)[self.regions count];
                region = [self.regions objectAtIndex:r];
                c = rand() % (int)[region.cells count];
                cell = [region.cells objectAtIndex:c];
            } while ( [cell.value charValue] != 0 );
            NSArray* possibles = [[self possibleForCell:cell] allObjects];
            if ( [possibles count] == 0 )
                continue;
            int v = rand() % (int)[possibles count];
            cell.value = [possibles objectAtIndex:v];
            cell.fixed = YES;
        }
    }
    return self;
}

-(NSSet*) possibleForCell:(Cell *)cell {
    char value = [cell.value charValue];
    if ( value != 0 )
        return [NSSet set];
    else {
        NSMutableSet* possibles = [NSMutableSet setWithSet:[[self.regions objectAtIndex:0] possibleForCell:cell andDim:self.dim]];
        for ( Region* region in self.regions ) {
            if ( [region.cells indexOfObject:cell] != NSNotFound ) {
                [possibles intersectSet:[region possibleForCell:cell andDim:self.dim]];
            }
        }
        NSArray* possiblesArray = [possibles allObjects];
        for ( NSNumber* first in possiblesArray ) {
            for ( NSNumber* second in possiblesArray ) {
                if ( first != second && [first charValue] == [second charValue] ) {
                    [possibles removeObject:second];
                    break;
                }
            }
        }
        return possibles;
    }
}

-(char) conflict {
    for ( Region* region in self.regions ) {
        char conflict = [region conflict];
        if ( conflict == conflict_found )
            return conflict_found;
    }
    return conflict_free;
}

-(BOOL) solve {
    NSMutableArray* solvedCells = [NSMutableArray array];
    NSMutableSet* unfixedCellsSet = [NSMutableSet setWithArray:[[self.regions objectAtIndex:0] cells]];
    for ( Region* region in self.regions )
        [unfixedCellsSet unionSet:[NSSet setWithArray:region.cells]];
    NSSet* unfixedCellsSetTemp = [NSSet setWithSet:unfixedCellsSet];
    for ( Cell* cell in unfixedCellsSetTemp )
        if ( cell.fixed )
            [unfixedCellsSet removeObject:cell];

    Region* region;
    Cell* cell;
    do {
        long r = rand() % [self.regions count];
        region = [self.regions objectAtIndex:r];
        long c = rand() % [region.cells count];
        cell = [region.cells objectAtIndex:c];
    } while ( cell.fixed );
    
    [solvedCells addObject:cell];
    
    do {
        cell.value = [NSNumber numberWithChar:0];
        NSArray* possibles = [[self possibleForCell:cell] allObjects];
        if ( [possibles count] == 0 ) {
            [solvedCells removeLastObject];
            if ( [solvedCells count] == 0 ) {
                NSLog(@"Unsolveable!");
                break;
            }
            cell = [solvedCells lastObject];
            continue;
        }
        long v = rand() % [possibles count];
        cell.value = [possibles objectAtIndex:v];
        [unfixedCellsSet removeObject:cell];
        do {
            long r = rand() % [self.regions count];
            region = [self.regions objectAtIndex:r];
            long c = rand() % [region.cells count];
            cell = [region.cells objectAtIndex:c];
        } while ( cell.fixed );
//        NSLog(@"Setting value! %@", [[solvedCells lastObject] value]);
        [solvedCells addObject:cell];
    } while ( [unfixedCellsSet count] );
    
    return YES;
}

-(NSString*) description {
    NSString* description = @"";
    for ( Region* region in self.regions )
        description = [description stringByAppendingFormat:@"%@\n", [region description]];
    return description;
}

@end
