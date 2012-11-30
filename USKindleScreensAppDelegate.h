//
//  USKindleScreensAppDelegate.h
//  USKindleScreens
//
//  Created by James Williams on 2/21/11.
//  Copyright 2011 Ungrounded Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "USCollectionView.h"
#import "USKindleImages.h"
#import "USAlert.h"

@interface USKindleScreensAppDelegate : NSObject <NSApplicationDelegate> {
	NSURL *kindleScreensDirectoryURL;
	NSUserDefaults *defaults;
	
	BOOL showingOpenWindow;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet USCollectionView *imagesView;
@property (assign) IBOutlet NSImageView *imagePreview;
@property (assign) IBOutlet NSView *openPanelAccessoryView;
@property (retain) USKindleImage *selectedImage;
@property (retain,readonly) NSURL *kindleScreensDirectoryURL;

@property (assign) IBOutlet NSArrayController *imagesController;
@property (retain) USKindleImages *images;
@property (assign) BOOL showingOpenWindow;

@property (assign) IBOutlet NSMenu *mainMenu;
@property (assign) IBOutlet NSToolbar *toolbar;
@property (assign) IBOutlet NSMenuItem *randomizeMenu;
@property (assign) IBOutlet NSMenuItem *renameMenu;

-(void)loadImagesForKindleDirectoryURL;
-(NSURL*)userHomeDirectory;
-(NSURL*)attemptToDiscoverKindleVolume;

-(IBAction)randomize:(id)sender;
-(IBAction)renameFiles:(id)sender;

-(IBAction)showWindow:(id)sender;
-(IBAction)closeWindow:(id)sender;
-(void)detectRandomFile;

-(IBAction)locateKindleImagesDirectory:(id)sender;
-(void)enableAndDisableUI;
@end
