//
//  USCollectionViewItem.m
//  Kindle Screen Manager
//
//  Created by James Williams on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "USCollectionViewItem.h"


@implementation USCollectionViewItem
@synthesize kindleImages;

-(void)awakeFromNib
{
}

- (void)dealloc
{
    [super dealloc];
}

-(void)setSelected:(BOOL)flag
{
    [super setSelected:flag];
    
    [(USCollectionItemView*)self.view setIsSelected:flag];
    [self.view setNeedsDisplay:YES];
}

-(IBAction)moveToTop:(id)sender
{
    USKindleImage *image = [self representedObject];

    [kindleImages moveImageToTop:image];
}

-(IBAction)moveToBottom:(id)sender
{
    USKindleImage *image = [self representedObject];
    
    [kindleImages moveImageToBottom:image];    
}

-(IBAction)moveUp:(id)sender
{
    USKindleImage *image = [self representedObject];
    
    [kindleImages moveImageUp:image];
}

-(IBAction)moveDown:(id)sender
{
    USKindleImage *image = [self representedObject];    
    
    [kindleImages moveImageDown:image];
}
@end
