//
//  Cell.m
//  Sudoku
//
//  Created by Mike Barriault on 12-01-07.
//  Copyright (c) 2012 Memorial University. All rights reserved.
//

#import "Cell.h"

@implementation Cell

@synthesize value = _value;
@synthesize fixed = _fixed;
@synthesize field = _field;

+(id) cell {
    return [Cell cellWithValue:0];
}

-(id) init {
    return [self initWithValue:0];
}

+(id) cellWithValue:(char)value {
    return [[Cell alloc] initWithValue:value];
}

-(id) initWithValue:(char)value {
    if ( self = [super init] ) {
        self.fixed = NO;
        self.value = [NSNumber numberWithChar:value];
    }
    return self;
}

-(NSString*) description {
    return [self.value description];
}

-(NSNumber*) value {
    return _value;
}

-(void) setValue:(NSNumber *)value {
    _value = value;
    if ( self.field && [value charValue] > 0 ) {
        [self.field setIntValue:[value intValue]];
    }
}

@end
