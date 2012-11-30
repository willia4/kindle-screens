//
//  USCollectionView.h
//  Kindle Screen Manager
//
//  Created by James Williams on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "USCollectionViewItem.h"
#import "USCollectionItemView.h"
#import "USKindleImages.h"

@interface USCollectionView : NSCollectionView {
@private
    
}

@property (assign) USKindleImages *kindleImages;
@end
