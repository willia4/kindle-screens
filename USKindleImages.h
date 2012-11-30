//
//  USKindleImages.h
//  USKindleScreens
//
//  Created by James Williams on 2/21/11.
//  Copyright 2011 Ungrounded Software. All rights reserved.
//

#import <stdlib.h>
#import <Cocoa/Cocoa.h>
#import "USKindleImage.h"

extern NSString *USKindleImages_DragAndDropDatatype;
extern NSString *USKindleImages_SelectionChanged;

@interface USKindleImages : NSObject <NSCollectionViewDelegate>
{
    NSArrayController *imagesController;
    NSMutableArray *imagesArray;

}
@property (nonatomic,retain) NSArray *images;

@property (nonatomic, copy) NSURL *kindleFolder;

-(id)initWithArrayController:(NSArrayController*)ac;

-(void)setImages:(NSArray*)newImages;
-(NSArray*)images;
-(void)updateIndexes;

-(void)randomize;

-(NSInteger)renameImages;

-(void)loadImagesFromFolder:(NSURL*)folder;

-(void)moveImageToTop:(USKindleImage*)image;
-(void)moveImageToBottom:(USKindleImage*)image;
-(void)moveImageUp:(USKindleImage*)image;
-(void)moveImageDown:(USKindleImage*)image;
@end
