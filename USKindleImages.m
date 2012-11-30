//
//  USKindleImages.m
//  USKindleScreens
//
//  Created by James Williams on 2/21/11.
//  Copyright 2011 Ungrounded Software. All rights reserved.
//

#import "USKindleImages.h"


NSString *USKindleImages_DragAndDropDatatype = @"USKindleImages";
NSString *USKindleImages_SelectionChanged = @"USKindleImages_SelectionChanged";

@implementation USKindleImages
@synthesize kindleFolder;

-(id)initWithArrayController:(NSArrayController*)ac;
{
	if([super init])
	{
		srandomdev();
		imagesArray = [NSMutableArray array];
        
        imagesController = ac;
        [imagesController addObserver:self
                           forKeyPath:@"selectionIndexes"
                              options:0
                              context:NULL];
        
        [imagesController bind:@"contentArray" toObject:self withKeyPath:@"imagesArray" options:nil];
        
	}

	return self;
}

-(void)setImages:(NSArray*)newImages
{	
	for(id o in newImages)
	{
		if(![o isKindOfClass:[USKindleImage class]])
			[[NSException exceptionWithName:@"USKindleImages_NeedsUSKindleImageArray" 
                                     reason:@"The array passed to setImages: must contain USKindleImage objects" 
                                   userInfo:nil] raise];
	}
	
    NSMutableArray *i = [NSMutableArray arrayWithArray:[newImages copy]];
    [i sortUsingSelector:@selector(compareIndexes:)];
    
    [imagesController removeObjects:[imagesController arrangedObjects]];
    [imagesController addObjects:i];
    
	[self updateIndexes];
	
    [imagesController setSelectionIndexes:[NSIndexSet indexSet]];
}

-(NSArray*)images
{
	return [[imagesController arrangedObjects] copy];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"selectionIndexes"])
    {
        USKindleImage *image = nil;
        if([[imagesController selectionIndexes] count] > 0)
        {
            image = [[imagesController arrangedObjects] 
                     objectAtIndex:[[imagesController selectionIndexes] firstIndex]];      
        }
        
		[[NSNotificationCenter defaultCenter] 
         postNotification:[NSNotification notificationWithName:USKindleImages_SelectionChanged 
                                                        object:image]];
    }
}

-(void)updateIndexes
{
    NSArray *arranged = [imagesController arrangedObjects];
    
	for(NSUInteger i = 0; i < [arranged count]; i++)
	{
		USKindleImage *k = [arranged objectAtIndex:i];
		k.index = i + 1;
	}
}

-(void)randomize
{
    NSMutableArray *imagesCopy = [NSMutableArray arrayWithArray:[self images]];
	NSUInteger count = [imagesCopy count];
	for(NSUInteger i = 0; i < count; i++)
	{
		int nElements = count - i;
		int n = (arc4random() % nElements) + i;
		[imagesCopy exchangeObjectAtIndex:i withObjectAtIndex:n];
	}
    [imagesController removeObjects:[self images]];
    [imagesController addObjects:imagesCopy];
	[self updateIndexes];
	
    [imagesController setSelectionIndexes:[NSIndexSet indexSet]];
    
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:USKindleImages_SelectionChanged object:nil]];
}

-(NSInteger)renameImages
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSInteger renameCount = 0;
	
	for(USKindleImage *image in [imagesController arrangedObjects])
	{
		if([image renameFileWithManager:fm])
			renameCount++;
	}
	
	[self loadImagesFromFolder:self.kindleFolder];
	
	return renameCount;
}

-(void)loadImagesFromFolder:(NSURL*)folder
{	
	self.kindleFolder = nil;
	NSError *error;

	if(!folder || ![folder isFileURL])
	{
		[self setImages:[NSArray array]];
		return;
	}
	
	if(![folder isFileURL] || ![folder checkResourceIsReachableAndReturnError:&error])
	{
		[[NSAlert alertWithError:error] runModal];
		[self setImages:[NSArray array]];
		return;
	}
	
	self.kindleFolder = folder;
	
	NSMutableArray *unparsedURLs = [NSMutableArray array];

	
	NSArray *urls = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:folder
												  includingPropertiesForKeys:nil
																	 options:NSDirectoryEnumerationSkipsHiddenFiles
																	   error:&error];
	if(!urls)
	{
		[[NSAlert alertWithError:error] runModal];
		[self setImages:[NSArray array]];
		return;
	}
	
	[unparsedURLs addObjectsFromArray:[urls filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"path endswith[c] '.png'"]]];
	[unparsedURLs addObjectsFromArray:[urls filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"path endswith[c] '.jpg'"]]];
	[unparsedURLs addObjectsFromArray:[urls filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"path endswith[c] '.jpeg'"]]];
	
	NSMutableArray *parsedImages = [NSMutableArray array];
	
	for(NSURL *fileURL in unparsedURLs)
	{
		[parsedImages addObject:[[USKindleImage alloc] initWithURL:fileURL]];
	}
	
	[self setImages:parsedImages];
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:USKindleImages_SelectionChanged object:nil]];
}

-(void)moveImageToTop:(USKindleImage*)image
{
    [imagesController removeObject:image];
    [imagesController insertObject:image atArrangedObjectIndex:0];
    [self updateIndexes];
}

-(void)moveImageToBottom:(USKindleImage*)image
{
    [imagesController removeObject:image];
    [imagesController addObject:image];
    [self updateIndexes];
}

-(void)moveImageUp:(USKindleImage*)image
{
    NSInteger currentIndex = [[imagesController arrangedObjects] indexOfObject:image];
    if(currentIndex <= 0)
        return;
    
    currentIndex--;
    if(currentIndex <= 0)
    {
        [self moveImageToTop:image];
        return;
    }
    
    [imagesController removeObject:image];
    [imagesController insertObject:image atArrangedObjectIndex:currentIndex];
}

-(void)moveImageDown:(USKindleImage*)image
{
    NSInteger currentIndex = [[imagesController arrangedObjects] indexOfObject:image];
    if(currentIndex >= [[imagesController arrangedObjects] count])
        return;
    
    currentIndex++;
    if(currentIndex >= [[imagesController arrangedObjects] count])
    {
        [self moveImageToBottom:image];
        return;
    }
    
    [imagesController removeObject:image];
    [imagesController insertObject:image atArrangedObjectIndex:currentIndex];
}

-(void)updateImagesControllerForNewArray:(NSArray*)newArray
{
    NSArray *arrangedObjects = [imagesController arrangedObjects];
    NSInteger count = [arrangedObjects count];
    
    for(NSInteger i = 0; i < count; i++)
    {
        id o1 = [arrangedObjects objectAtIndex:i];
        id o2 = [newArray objectAtIndex:i];
        
        if(o1 != o2)
        {
            [imagesController insertObject:o2 atArrangedObjectIndex:i];
            [imagesController removeObjectAtArrangedObjectIndex:i+1];

        }
    }
}

/* Drag and Drop! */
-(BOOL)collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent*)event
{
    return YES;
}

-(BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id < NSDraggingInfo >)draggingInfo index:(NSInteger)index dropOperation:(NSCollectionViewDropOperation)dropOperation
{
    /*  This took me too long to figure out, and it looks a little weird. The basic idea is: 
     
        originalArray is a stack consisting of all the objects in the original images array.
        
        newArray is where we do the work and will eventually become the images array. 
        
        objectsNotToCopy is a fixed array consisting of the dragged items. Anything in this array will not be 
        copied straight over from originalArray. 
        
        objectsToMove is a stack which also starts out consisting of the dragged items. 
     
     ***
        Walk through all of the indexes. If we hit the index that we're supposed to start dragging through,
        pop an item off of objectsToMove and push it onto newArray. 
     
        If we hit a different index, pop the item off of originalArray. Make sure it's not in 
        objectsNotToCopy. If it isn't, add it to newArray. Otherwise, ignore it. 
     
     ***
        Additional tricky or clever bits are called out in the code. 
     */
    
    NSPasteboard *pboard = [draggingInfo draggingPasteboard];
    NSData *fromData = [pboard dataForType:USKindleImages_DragAndDropDatatype];
    NSIndexSet *fromIndexSet = [NSKeyedUnarchiver unarchiveObjectWithData:fromData];
    
    NSMutableArray *originalArray = [NSMutableArray arrayWithArray:[imagesController arrangedObjects]];
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:[originalArray count]];
    NSInteger originalCount = [originalArray count];
    
    NSArray *objectsNotToCopy = [[imagesController arrangedObjects] objectsAtIndexes:fromIndexSet];
    NSMutableArray *objectsToMove = [NSMutableArray arrayWithArray:objectsNotToCopy];

    //make sure to calculate this before we change index in the loop
    NSIndexSet *selectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, [objectsToMove count])];
     
    
    //When we get to an index that we need to insert into, we don't pop from the original array. 
    //This means that some items might get skipped: so add the number of objects we're copying 
    //to the originalCount so we don't skip those.
    for(NSInteger i = 0; i < originalCount + [fromIndexSet count]; i++)
    {
        if(i == index && [objectsToMove count] > 0)
        {
            id o = [objectsToMove objectAtIndex:0];
            [objectsToMove removeObjectAtIndex:0];
            
            [newArray addObject:o];
            index++; //increment index so we'll keep coming in here for as long as we have objects to move
        }
        else
        {
            if([originalArray count] > 0)
            {
                id o = [originalArray objectAtIndex:0];
                [originalArray removeObjectAtIndex:0];
                
                if(![objectsNotToCopy containsObject:o])
                    [newArray addObject:o];                
            }
        }
    }
    
    [self updateImagesControllerForNewArray:newArray];
    
    [imagesController setSelectionIndexes:selectedIndexes];
    
    [self updateIndexes];
    
    return YES;
}

-(NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id < NSDraggingInfo >)draggingInfo proposedIndex:(NSInteger *)proposedDropIndex dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation
{
        return NSDragOperationMove;
}

-(NSArray *)collectionView:(NSCollectionView *)collectionView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropURL forDraggedItemsAtIndexes:(NSIndexSet *)indexes
{
    return nil;
}

-(BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard
{
    //The pasteboard data that we're dragging is just an NSData of the dragged indexes. 
    //Sheer elegance in its simplicity. 
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:indexes];
    [pasteboard declareTypes:[NSArray arrayWithObject:USKindleImages_DragAndDropDatatype] owner:self];
    [pasteboard setData:data forType:USKindleImages_DragAndDropDatatype];
    return YES;
}
@end
