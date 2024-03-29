//
//  Grid.m
//  Sudoku
//
//  Created by Mike Barriault on 12-01-07.
//  Copyright (c) 2012 Memorial University. All rights reserved.
//

#import "Grid.h"
#import "NSSet+Random.h"

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
        //[NSThread detachNewThreadSelector:@selector(generate:) toTarget:self withObject:[NSNumber numberWithChar:20]];
//        [self generate];
/*        for ( int n=0; n<33; n++ ) {
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
        }*/
    }
    return self;
}

-(NSSet*) possibleForCell:(Cell *)cell {
    char value = [cell.value charValue];
    if ( value != 0 )
        return [NSSet set];
    else {
        NSMutableSet* possibles = [NSMutableSet setWithSet:[[self.regions objectAtIndex:0] possibleForDim:self.dim]];
        for ( Region* region in self.regions ) {
            if ( [region.cells indexOfObject:cell] != NSNotFound ) {
                [possibles intersectSet:[region possibleForDim:self.dim]];
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

-(void) generate:(NSNumber*)count {
    srand((unsigned int)time(NULL));
    
    NSMutableSet* cellsSet = [NSMutableSet set];
    for ( Region* region in self.regions )
        [cellsSet unionSet:[NSSet setWithArray:region.cells]];
    NSArray* cells = [cellsSet allObjects];
    NSMutableArray* setCells = [NSMutableArray arrayWithCapacity:[cellsSet count]];
    NSMutableSet* unsetCells = [NSMutableSet setWithArray:[cells copy]];
    
    while ( [unsetCells count] > 0 ) {
        Cell* cell = [unsetCells randomObject];
        NSSet* possibles = [self possibleForCell:cell];
        if ( [possibles count] == 0 ) {
            Cell* other = [setCells lastObject];
            other.value = [NSNumber numberWithChar:0];
            other.fixed = NO;
            [setCells removeObject:other];
            [unsetCells addObject:other];
        }
        else {
            cell.value = [possibles randomObject];
            if ( [count intValue] > [setCells count] )
                cell.fixed = YES;
            else
                cell.fixed = NO;
            [setCells addObject:cell];
            [unsetCells removeObject:cell];
        }
    }
    
    
/*    for ( int n=0; n<count; n++ ) {
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
    }*/
}

-(BOOL) solve {
    NSMutableSet* cellsSet = [NSMutableSet set];
    for ( Region* region in self.regions )
        [cellsSet unionSet:[NSSet setWithArray:region.cells]];
    NSArray* cells = [[cellsSet allObjects] sortedArrayUsingComparator:^(Cell* a, Cell* b) {
        NSUInteger nA = [[self possibleForCell:a] count];
        NSUInteger nB = [[self possibleForCell:b] count];
        if ( nA > nB )
            return (NSComparisonResult)NSOrderedDescending;
        else if ( nA < nB )
            return (NSComparisonResult)NSOrderedAscending;
        else
            return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSInteger index = 0;
    
    do {
        Cell* cell = [cells objectAtIndex:index];
        NSMutableSet* possibles = [NSMutableSet setWithSet:[self possibleForCell:cell]];
        if ( [possibles count] == 0 && [cell.value charValue] > 0 ) {
            index++;
            continue;
        }
        else if ( [possibles count] == 0 ) {
            do {
                cell.value = [NSNumber numberWithChar:0];
                index--;
                cell = [cells objectAtIndex:index];
            } while ( [[self possibleForCell:cell] count] < 1 );
        }
        for ( NSNumber* possible in possibles )
            if ( [possible charValue] == [cell.value charValue] ) {
                [possibles removeObject:possible];
                break;
            }
        cell.value = [possibles anyObject];
        index++;
    } while ( index < [cells count] );
    
    return NO;
}

-(BOOL) solveOld {
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
