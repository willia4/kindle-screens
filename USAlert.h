//
//  USAlert.h
//  Kindle Screen Manager
//
//  Created by James Williams on 2/27/11.
//  Copyright 2011 Ungrounded Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//NSAlert wrapper that supports completion handlers.

@interface USAlert : NSObject {
	NSAlert *innerAlert;
	void (^completionHandler)(NSInteger);
	
	NSWindow *delayedSheetWindow;
	void (^delayedCompletionHandler)(NSInteger);
}
@property (readonly, retain) NSAlert *innerAlert;

+(USAlert*)init;
+(USAlert*)alertWithAlert:(NSAlert*)alert;
+(USAlert*)alertWithError:(NSError*)error;
+(USAlert*)alertWithMessageText:(NSString *)messageTitle defaultButton:(NSString *)defaultButtonTitle alternateButton:(NSString *)alternateButtonTitle otherButton:(NSString *)otherButtonTitle informativeText:(NSString *)informativeText;

-(id)initWithNSAlert:(NSAlert*)a;

-(void)beginSheetModalForWindow:(NSWindow*)window completionHandler:(void (^)(NSInteger result))handler;
-(NSInteger)runModal;
-(NSInteger)runModalWithCompletionHandler:(void (^)(NSInteger result))handler;

-(void)beginSheetModalForWindow:(NSWindow*)window completionHandler:(void (^)(NSInteger result))handler afterDelay:(NSInteger)delay;
-(void)runModalWithCompletionHandler:(void (^)(NSInteger result))handler afterDelay:(NSInteger)delay;

-(void)dismissWindow;

//NSAlert forwards
-(void)setMessageText:(NSString *)messageText;
-(void)setInformativeText:(NSString *)informativeText;
-(NSString *)messageText;
-(NSString *)informativeText;
-(void)setIcon:(NSImage *)icon;
-(NSImage *)icon;
-(NSButton *)addButtonWithTitle:(NSString *)title;
-(NSArray *)buttons;
-(void)setShowsHelp:(BOOL)showsHelp;
-(BOOL)showsHelp;
-(void)setHelpAnchor:(NSString *)anchor;
-(NSString *)helpAnchor;
-(void)setAlertStyle:(NSAlertStyle)style;
-(NSAlertStyle)alertStyle;
-(void)setDelegate:(id <NSAlertDelegate>)delegate;
-(id <NSAlertDelegate>)delegate;
-(void)setShowsSuppressionButton:(BOOL)flag;
-(BOOL)showsSuppressionButton;
-(NSButton *)suppressionButton;
-(void)setAccessoryView:(NSView *)view;
-(NSView *)accessoryView;
-(void)layout;
-(id)window;
@end
