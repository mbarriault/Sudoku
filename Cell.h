//
//  Cell.h
//  Sudoku
//
//  Created by Mike Barriault on 12-01-07.
//  Copyright (c) 2012 Memorial University. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface Cell : NSObject

@property (strong, readwrite) NSNumber* value;
@property (readwrite) BOOL fixed;
@property (weak, readwrite) id field;

+(id) cell;
+(id) cellWithValue:(char)value;
-(id) initWithValue:(char)value;

@end
