//
//  USKindleImage.h
//  USKindleScreens
//
//  Created by James Williams on 2/21/11.
//  Copyright 2011 Ungrounded Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface USKindleImage : NSObject {
	NSImage *image;
    NSInteger index;
}
@property(copy,nonatomic) NSURL *originalFilePathURL;
@property(copy,nonatomic) NSString *originalFileName;
@property(copy,nonatomic) NSString *parsedFileName;
@property(copy,nonatomic) NSString *fileExtension;
@property(assign,nonatomic) NSInteger index;
@property(retain,readonly) NSImage *image;

-(void)parseOriginalFilePathURL;
-(id)initWithURL:(NSURL*)u;
-(NSString*)indexString;

-(NSComparisonResult)compareNames:(USKindleImage*)other;
-(NSComparisonResult)compareIndexes:(USKindleImage*)other;

-(NSString*)newFileName;
-(BOOL)renameFileWithManager:(NSFileManager*)f;
@end
