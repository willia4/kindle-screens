//
//  USCollectionView.m
//  Kindle Screen Manager
//
//  Created by James Williams on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "USCollectionView.h"


@implementation USCollectionView

@synthesize kindleImages;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(NSCollectionViewItem *)newItemForRepresentedObject:(id)object
{
    USCollectionViewItem *item = (USCollectionViewItem*)[super newItemForRepresentedObject:object];
    item.kindleImages = self.kindleImages;
    [(USCollectionItemView*)item.view performInitialization];
    return item;
}

@end
