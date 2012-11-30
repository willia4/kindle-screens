//
//  USCollectionItemView.m
//  Kindle Screen Manager
//
//  Created by James Williams on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "USCollectionItemView.h"


@implementation USCollectionItemView
@synthesize isSelected;

- (void)drawRect:(NSRect)dirtyRect
{
    NSColor *selectedColor = [NSColor selectedControlColor];
    NSColor *backgroundColor = [NSColor clearColor]; //Drawing a clear background lets the NSColorView draw alternating rows

    NSRect bounds = self.bounds;
    
    NSColor *gridColor = [NSColor gridColor];

    NSBezierPath *path = [NSBezierPath bezierPathWithRect:bounds];
    
    if(self.isSelected)
        [selectedColor set];
    else
        [backgroundColor set];
    
    [path fill];
    
    NSPoint bottomLeft = NSMakePoint(bounds.origin.x, bounds.origin.y);
    
    path = [NSBezierPath bezierPathWithRect:NSMakeRect(bottomLeft.x, bottomLeft.y, bounds.size.width, 1)];
    [gridColor set];
    [path setLineWidth:2];
    [path stroke];
}

-(void)setButtonsHidden:(BOOL)hidden
{
    for(NSButton *b in buttons)
    {
        [[b animator] setHidden:hidden];
    }
}

-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    [self setButtonsHidden:NO];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    [self setButtonsHidden:YES];    
}

-(void)performInitialization
{
    buttons = [NSMutableArray arrayWithCapacity:4];
    
    for(NSView *v in [self subviews])
    {
        if([v isKindOfClass:[NSButton class]])
        {
            if([v tag] == 1)
                [buttons addObject:v];
        }
    }
    
    [self resetTrackingArea];
}

-(void)resetTrackingArea
{
    for(NSTrackingArea *t in [self trackingAreas])
        [self removeTrackingArea:t];
    
    NSTrackingArea *t = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                       owner:self
                                                    userInfo:nil];
    [self addTrackingArea:t]; 
}

-(void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self resetTrackingArea];
}

-(void)setFrameSize:(NSSize)newSize
{
    [super setFrameSize:newSize];
    [self resetTrackingArea];
}
@end
