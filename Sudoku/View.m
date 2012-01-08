//
//  View.m
//  Sudoku
//
//  Created by Mike Barriault on 12-01-07.
//  Copyright (c) 2012 Memorial University. All rights reserved.
//

#import "View.h"

@implementation View

@synthesize grid = _grid;

- (id)initWithFrame:(NSRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        int dim = 3;
        int rsize = pow(dim,2);
        _grid = [Grid gridWithDim:dim andRandoms:0.25];
        
        CGFloat width = floor((self.frame.size.width-rsize+1)/rsize);
        CGFloat height = floor((self.frame.size.height-rsize+1)/rsize);
        
        for ( int i=0; i<rsize; i++ ) for ( int j=0; j<rsize; j++ ) {
            Region* region = [self.grid.regions objectAtIndex:i];
            Cell* cell = [region.cells objectAtIndex:j];
            
            NSRect cellRect = NSMakeRect(self.frame.origin.x+i*width+i, self.frame.origin.y+j*width+j, width, height);
            NSTextField* field = [[NSTextField alloc] initWithFrame:cellRect];
            [field setEditable:NO];
            [field setBackgroundColor:[NSColor clearColor]];
            [field setBordered:NO];
            [field setAlignment:NSCenterTextAlignment];
            [field setTag:i*rsize+j];
            cell.field = field;
            
            if ( [cell.value charValue] != 0 ) {
                [field setIntValue:[cell.value intValue]];
                [field setTextColor:[NSColor blueColor]];
            }
            else
                [field setStringValue:@" "];
            
            [self addSubview:field];
        }
        
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGPoint origin = dirtyRect.origin;
    CGSize size = dirtyRect.size;
    int dim = self.grid.dim;
    int rsize = pow(dim, 2);
    CGFloat height = floor((self.frame.size.height-(rsize-1))/rsize);
    CGFloat width = floor((self.frame.size.width-(rsize-1))/rsize);

    for ( NSTextField* field in self.subviews ) {
        long row = [field tag]/rsize;
        long col = [field tag]%rsize;
        NSRect cellRect = NSMakeRect(self.frame.origin.x+row*width+row, self.frame.origin.y+col*height+col, width, height);
        [field setFrame:cellRect];
        
        if ( [[field stringValue] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@" "]].location != NSNotFound )
            [field setFont:[NSFont fontWithName:@"Helvetica" size:height*0.3]];
        else if ( [field intValue] > 9 )
            [field setFont:[NSFont fontWithName:@"Helvetica" size:height*0.65]];
        else
            [field setFont:[NSFont fontWithName:@"Helvetica" size:height*0.8]];
    }
    
    [[NSColor grayColor] set];
    for ( int i=1; i<rsize; i++ )
        NSRectFill(NSMakeRect(origin.x+i*size.width/rsize, 0., 1., size.height));
    for ( int j=1; j<rsize; j++ )
        NSRectFill(NSMakeRect(0., origin.y+j*size.height/rsize, size.width, 1.));
    
    [[NSColor blackColor] set];
    for ( int I=1; I<dim; I++ )
        NSRectFill(NSMakeRect(origin.x+I*size.width/dim, 0., 1., size.height));
    for ( int J=1; J<dim; J++ )
        NSRectFill(NSMakeRect(0., origin.y+J*size.height/dim, size.width, 1.));
}

-(void) mouseDown:(NSEvent *)theEvent {
    if ( [theEvent clickCount] >= 1 ) {
        NSPoint loc = [theEvent locationInWindow];
        NSSize windowSize = self.frame.size;
        int i = pow(self.grid.dim,2)*loc.x / windowSize.width;
        int j = pow(self.grid.dim,2)*loc.y / windowSize.height;
        
        Region* region = [[self.grid regions] objectAtIndex:i];
        Cell* cell = [region.cells objectAtIndex:j];
        if ( !cell.fixed ) {
            NSTextField* field = cell.field;
            [field setEditable:YES];
            [field selectText:self];
            [field setTarget:self];
            [field setAction:@selector(finishEditing:)];
        }
    }
}

-(void) finishEditing:(id)sender {
    [sender setEditable:FALSE];
    [sender setTarget:sender];
    [sender setAction:nil];
    int rsize = pow(self.grid.dim,2);
    long row = [sender tag]/rsize;
    long col = [sender tag]%rsize;
    if ( [[sender stringValue] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@" "]].location == NSNotFound ) {
        Region* region = [self.grid.regions objectAtIndex:row];
        Cell* cell = [region.cells objectAtIndex:col];
        cell.value = [NSNumber numberWithChar:[sender intValue]];
        
        [sender setTextColor:[NSColor blackColor]];
        for ( Region* region in self.grid.regions ) {
            if ( [region.cells indexOfObject:cell] != NSNotFound ) {
                if ( [region conflict] == conflict_found ) {
                    [sender setTextColor:[NSColor redColor]];
                    break;
                }
            }
        }
    }
    else {
        [sender setTextColor:[NSColor grayColor]];
    }
    [self setNeedsDisplay:YES];
}

@end
