//
//  USCollectionViewItem.h
//  Kindle Screen Manager
//
//  Created by James Williams on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "USCollectionItemView.h"
#import "USKindleImage.h"
#import "USKindleImages.h"

@interface USCollectionViewItem : NSCollectionViewItem {
@private
    
}
@property(retain) IBOutlet USKindleImages *kindleImages;

-(IBAction)moveToTop:(id)sender;
-(IBAction)moveToBottom:(id)sender;
-(IBAction)moveUp:(id)sender;
-(IBAction)moveDown:(id)sender;
@end
