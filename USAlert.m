//
//  USAlert.m
//  Kindle Screen Manager
//
//  Created by James Williams on 2/27/11.
//  Copyright 2011 Ungrounded Software. All rights reserved.
//

#import "USAlert.h"

@interface USAlert (USAlert_Private)

+(NSAlert*)emptyAlert;
-(void)innerAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

-(void)setCompletionHandler:(void (^)(NSInteger r))c;

-(void)setDelayedSheetWindow:(NSWindow*)w;
-(void)setDelayedCompletionHandler:(void (^)(NSInteger r))dc;
@end


@implementation USAlert
@synthesize innerAlert;

+(USAlert*)init
{
	return [[[USAlert alloc] initWithNSAlert:[USAlert emptyAlert]] autorelease];
}

+(USAlert*)alertWithAlert:(NSAlert*)alert
{
	return [[[USAlert alloc] initWithNSAlert:alert] autorelease];
}

+(USAlert*)alertWithError:(NSError*)error
{
	return [[[USAlert alloc] initWithNSAlert:[NSAlert alertWithError:error]] autorelease];
}

+(USAlert*)alertWithMessageText:(NSString *)messageTitle defaultButton:(NSString *)defaultButtonTitle alternateButton:(NSString *)alternateButtonTitle otherButton:(NSString *)otherButtonTitle informativeText:(NSString *)informativeText
{
	if(!informativeText)
		informativeText = @"";
	
	return [[[USAlert alloc] initWithNSAlert:[NSAlert alertWithMessageText:messageTitle
															 defaultButton:defaultButtonTitle
														   alternateButton:alternateButtonTitle
															   otherButton:otherButtonTitle
												 informativeTextWithFormat:@"%@", informativeText]] autorelease];
}

+(NSAlert*)emptyAlert
{
	return [[[NSAlert alloc] init] autorelease];
}

-(id)init
{
	return [self initWithNSAlert:[USAlert emptyAlert]];
}

-(id)initWithNSAlert:(NSAlert*)a
{
	NSAssert(a, @"Cannot init with empty NSAlert");
	
	if((self = [super init]))
	{
		completionHandler = nil;
		innerAlert = [a retain];
		
		delayedSheetWindow = nil;
		delayedCompletionHandler = nil;
	}
	return self;
}

-(void)dealloc
{
	[innerAlert release];
	if(completionHandler)
		Block_release(completionHandler);
	
	[delayedSheetWindow release];
	if(delayedCompletionHandler)
		Block_release(delayedCompletionHandler);
	
	[super dealloc];
}

-(void)setCompletionHandler:(void (^)(NSInteger r))c
{
	if(completionHandler)
		Block_release(completionHandler);
	
	if(c)
		completionHandler = Block_copy(c);
	else
		c = nil;
}

-(void)setDelayedSheetWindow:(NSWindow*)w
{
	[w retain];
	[delayedSheetWindow release];
	delayedSheetWindow = w;
}

-(void)setDelayedCompletionHandler:(void (^)(NSInteger r))dc
{
	if(delayedCompletionHandler)
		Block_release(delayedCompletionHandler);
	
	if(dc)
		delayedCompletionHandler = Block_copy(dc);
	else
		delayedCompletionHandler = nil;
}

-(NSInteger)runModal
{
	return [innerAlert runModal];
}

-(void)beginSheetModalForWindow:(NSWindow*)window completionHandler:(void (^)(NSInteger result))handler
{
	[self setCompletionHandler:handler];
	
	[innerAlert beginSheetModalForWindow:window
						   modalDelegate:self
						  didEndSelector:@selector(innerAlertDidEnd:returnCode:contextInfo:)
							 contextInfo:NULL];
}

-(void)innerAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	if(completionHandler)
		completionHandler(returnCode);
}

-(NSInteger)runModalWithCompletionHandler:(void (^)(NSInteger result))handler
{
	NSInteger r = [innerAlert runModal];
	if(handler)
		handler(r);
	return r;
}

-(void)runDelayedAction
{
	if(delayedSheetWindow)
	{		
		[self beginSheetModalForWindow:delayedSheetWindow completionHandler:delayedCompletionHandler];
	}
	else
	{
		[self runModalWithCompletionHandler:delayedCompletionHandler];
	}
}

-(void)beginSheetModalForWindow:(NSWindow*)window completionHandler:(void (^)(NSInteger result))handler afterDelay:(NSInteger)delay
{
	[self setDelayedSheetWindow:window];
	[self setDelayedCompletionHandler:handler];
	
	[self performSelector:@selector(runDelayedAction) withObject:nil afterDelay:delay];
}

-(void)runModalWithCompletionHandler:(void (^)(NSInteger result))handler afterDelay:(NSInteger)delay
{
	[self setDelayedSheetWindow:nil];
	[self setDelayedCompletionHandler:handler];
	
	[self performSelector:@selector(runDelayedAction) withObject:nil afterDelay:delay];
}

-(void)dismissWindow
{
	[[innerAlert window] orderOut:self];
}

#pragma mark NSAlert forwards
-(id)forwardingTargetForSelector:(SEL)sel 
{ 
	if([innerAlert respondsToSelector:sel])
		return innerAlert;
	return nil;
}
-(void)setMessageText:(NSString *)messageText { [innerAlert setMessageText:messageText]; } 
-(void)setInformativeText:(NSString *)informativeText { [innerAlert setInformativeText:informativeText]; }
-(NSString *)messageText { return [innerAlert messageText]; }
-(NSString *)informativeText { return [innerAlert informativeText]; }
-(void)setIcon:(NSImage *)icon { [innerAlert setIcon:icon]; }
-(NSImage *)icon { return [innerAlert icon]; }
-(NSButton *)addButtonWithTitle:(NSString *)title { return [innerAlert addButtonWithTitle:title]; }
-(NSArray *)buttons { return [innerAlert buttons]; }
-(void)setShowsHelp:(BOOL)showsHelp { [innerAlert showsHelp]; }
-(BOOL)showsHelp { return [innerAlert showsHelp]; }
-(void)setHelpAnchor:(NSString *)anchor { [innerAlert setHelpAnchor:anchor]; }
-(NSString *)helpAnchor { return [innerAlert helpAnchor]; }
-(void)setAlertStyle:(NSAlertStyle)style { [innerAlert setAlertStyle:style]; }
-(NSAlertStyle)alertStyle { return [innerAlert alertStyle];}
-(void)setDelegate:(id <NSAlertDelegate>)delegate { [innerAlert setDelegate:delegate]; }
-(id <NSAlertDelegate>)delegate { return [innerAlert delegate]; }
-(void)setShowsSuppressionButton:(BOOL)flag { [innerAlert setShowsSuppressionButton:flag]; }
-(BOOL)showsSuppressionButton { return [innerAlert showsSuppressionButton]; }
-(NSButton *)suppressionButton { return [innerAlert suppressionButton]; }
-(void)setAccessoryView:(NSView *)view { [innerAlert setAccessoryView:view]; }
-(NSView *)accessoryView  { return [innerAlert accessoryView]; }
-(void)layout { [innerAlert layout]; }
-(id)window  { return [innerAlert window]; }
@end
