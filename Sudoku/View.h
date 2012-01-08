//
//  View.h
//  Sudoku
//
//  Created by Mike Barriault on 12-01-07.
//  Copyright (c) 2012 Memorial University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Grid.h"

@interface View : NSView

@property (strong, readonly) Grid* grid;

@end
