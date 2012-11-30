//
//  USCollectionItemView.h
//  Kindle Screen Manager
//
//  Created by James Williams on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "USCollectionView.h"

@interface USCollectionItemView : NSView {
@private
    NSMutableArray *buttons;
}

@property(assign) BOOL isSelected;

-(void)performInitialization;
-(void)resetTrackingArea;
@end
