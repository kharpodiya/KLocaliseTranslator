//
//  drag.m
//  Translate
//
//  Created by Mav on 18/05/20.
//  Copyright © 2020 Mav. All rights reserved.
//

#import "drag.h"

@implementation drag
NSString * filePath = @"";


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    
        return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSLog(@"draggingEntered");
        highlight = YES;
        [self setNeedsDisplay: YES];
        return NSDragOperationLink;
}


- (void)draggingExited:(id<NSDraggingInfo>)sender {
    
    NSLog(@"draggingExited");
    
    highlight = NO;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    
    if (highlight) {
        [[NSColor grayColor]set];
        [NSBezierPath setDefaultLineWidth:10];
        [NSBezierPath strokeRect:dirtyRect];
    }
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    NSLog(@"prepareForDragOperation");
    highlight = NO;
    [self setNeedsDisplay:YES];
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    filePath = [draggedFilenames objectAtIndex:0];
     if ([[[draggedFilenames objectAtIndex:0] pathExtension] isEqual:@"strings"])
         return YES;
     else
         return NO;
}


-(void)concludeDragOperation:(id<NSDraggingInfo>)sender{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"dragNotification"
     object:filePath];

}



- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender{
    return NSDragOperationCopy;

}


- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {

    return YES;
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender{
    NSLog(@"ended");


}

@end
