//
//  USKindleImage.m
//  USKindleScreens
//
//  Created by James Williams on 2/21/11.
//  Copyright 2011 Ungrounded Software. All rights reserved.
//

#import "USKindleImage.h"


@implementation USKindleImage
@synthesize originalFilePathURL;
@synthesize originalFileName;
@synthesize fileExtension;
@synthesize parsedFileName;

-(id)initWithURL:(NSURL*)u
{
	if((self = [super init]))
	{
		self.originalFilePathURL = u;
		self.originalFileName = [[u pathComponents] lastObject];
		[self parseOriginalFilePathURL];	
	}
	return self;
}

-(void)parseOriginalFilePathURL
{
	fileExtension = [self.originalFileName pathExtension];
	
	NSScanner *scan = [NSScanner localizedScannerWithString:self.originalFileName];
	NSInteger tempIndex; 
	
	if([scan scanInteger:&tempIndex])
	{
		self.index = tempIndex;
		NSString *tempString; 
		[scan scanString:@"_" intoString:NULL];
		
		if([scan scanUpToString:@"" intoString:&tempString])
		{	
			self.parsedFileName = tempString;
		}
		else
			self.parsedFileName = self.originalFileName;
	}
	else
	{
		self.index = NSIntegerMax;
		self.parsedFileName = self.originalFileName;
	}
}

-(NSInteger)index
{ 
    return index;
}

-(void)setIndex:(NSInteger)i
{
    //Make KVO work with indexString whenever index changes. 
    [self willChangeValueForKey:@"indexString"];
    [self willChangeValueForKey:@"index"];
    index = i;
    [self didChangeValueForKey:@"index"];
    [self didChangeValueForKey:@"indexString"];
}

-(NSString*)indexString
{
	if(index == NSIntegerMax)
		return @"MAX";
	return [NSString stringWithFormat:@"%ld", (long)self.index];
}

-(NSComparisonResult)compareNames:(USKindleImage*)other
{
	return [self.parsedFileName compare:other.parsedFileName];
}

-(NSComparisonResult)compareIndexes:(USKindleImage*)other
{
	if(self.index < other.index)
		return NSOrderedAscending;
	else if(self.index > other.index)
		return NSOrderedDescending;
	return [self compareNames:other];
}

-(NSImage*)image
{

	if(image)
		return image;

	image = [[NSImage alloc] initWithContentsOfURL:self.originalFilePathURL];
	return image;
}

-(NSString*)newFileName
{
	return [NSString stringWithFormat:@"%05ld_%@", (long)self.index, self.parsedFileName];
}

-(BOOL)renameFileWithManager:(NSFileManager*)f
{
	NSString *newFileName = [self newFileName];
	
	if(![newFileName isEqualToString:self.originalFileName])
	{
		NSURL *newURL = [self.originalFilePathURL URLByDeletingLastPathComponent];
		newURL = [newURL URLByAppendingPathComponent:newFileName];
		
		NSError *e = nil;
		
		if(![f moveItemAtURL:self.originalFilePathURL toURL:newURL error:&e])
		{
			NSLog(@"Error: %@", e);
		}
		return YES;
	}

	return NO;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"%ld: %@", self.index, self.parsedFileName];
}
@end
