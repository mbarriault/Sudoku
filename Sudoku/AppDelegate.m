//
//  AppDelegate.m
//  Sudoku
//
//  Created by Mike Barriault on 12-01-07.
//  Copyright (c) 2012 Memorial University. All rights reserved.
//

#import "AppDelegate.h"
#import "Cell.h"
#import "Region.h"
#import "Grid.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize view = _view;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
//    [NSThread detachNewThreadSelector:@selector(solve) toTarget:self.view.grid withObject:nil];
//    [self.view.grid solve];
}

@end
