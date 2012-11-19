//
//  Grid.h
//  Sudoku
//
//  Created by Mike Barriault on 12-01-07.
//  Copyright (c) 2012 Memorial University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cell.h"
#import "Region.h"

@interface Grid : NSObject

@property (strong, readonly) NSArray* regions;
@property (readonly) int dim;

+(id) grid;
+(id) gridWithDim:(int)dim;
-(id) initWithDim:(int)dim;
+(id) gridWithDim:(int)dim andRandoms:(float)givens;
-(id) initWithDim:(int)dim andRandoms:(float)givens;
-(NSSet*) possibleForCell:(Cell*)cell;
-(void) generate:(NSNumber*)count;
-(char) conflict;
-(BOOL) solve;

@end
