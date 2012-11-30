//
//  USKindleScreensAppDelegate.m
//  USKindleScreens
//
//  Created by James Williams on 2/21/11.
//  Copyright 2011 Ungrounded Software. All rights reserved.
//

#import "USKindleScreensAppDelegate.h"

NSString *USKindleScreensApp_Preferences_LastKindleScreensLocation = @"USKindleScreensApp_Preferences_LastKindleScreensLocation";

@implementation USKindleScreensAppDelegate

@synthesize window;
@synthesize imagesView;
@synthesize images;
@synthesize imagePreview;
@synthesize openPanelAccessoryView;
@synthesize selectedImage;
@synthesize kindleScreensDirectoryURL;
@synthesize imagesController;
@synthesize showingOpenWindow;
@synthesize randomizeMenu;
@synthesize renameMenu;
@synthesize mainMenu;
@synthesize toolbar;

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[[self attemptToDiscoverKindleVolume] path], USKindleScreensApp_Preferences_LastKindleScreensLocation, nil]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(photoSelectionChanged:)
												 name:USKindleImages_SelectionChanged
											   object:nil];
	
	self.images = [[USKindleImages alloc] initWithArrayController:self.imagesController];

    self.showingOpenWindow = NO;
	[self loadImagesForKindleDirectoryURL];
	
    [self.imagesView setDelegate:self.images];
    [self.imagesView registerForDraggedTypes:[NSArray arrayWithObject:USKindleImages_DragAndDropDatatype]];
    [self.imagesView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    
    self.imagesView.kindleImages = self.images;
    
	kindleScreensDirectoryURL = nil;
}

-(NSURL*)userHomeDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSUserDirectory inDomains:NSAllDomainsMask] objectAtIndex:0];
}

-(NSURL*)attemptToDiscoverKindleVolume
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSURL *r = [self userHomeDirectory]; //Default for if we can't find something better.
	
	NSURL *volumesFolder = [NSURL fileURLWithPath:@"/Volumes"];
	NSURL *kindleVolume = nil;
	NSURL *screensaverDirectory = nil;
	
	for(NSURL *volume in [fm contentsOfDirectoryAtURL:volumesFolder
						   includingPropertiesForKeys:nil
											  options:0
												error:NULL])
	{
		if([[volume lastPathComponent] isEqualToString:@"Kindle"])
		{
			if([fm isReadableFileAtPath:[volume path]])
			{
				kindleVolume = volume;
				break;
			}
		}
	}

	if(kindleVolume)
	{
		r = kindleVolume;
		BOOL isDirectory = NO;
		
		screensaverDirectory = [kindleVolume URLByAppendingPathComponent:@"linkss"];
		if([fm fileExistsAtPath:[screensaverDirectory path] isDirectory:&isDirectory])
		{
			if(isDirectory)
			{
				screensaverDirectory = [screensaverDirectory URLByAppendingPathComponent:@"screensavers"];
				if([fm fileExistsAtPath:[screensaverDirectory path] isDirectory:&isDirectory])				
				{
					if(isDirectory)
						r = screensaverDirectory;
				}
			}
		}
	}

	return r;
}

-(NSURL*)kindleSearchStartURL
{
	NSURL *startLocation = nil;
	if([defaults URLForKey:USKindleScreensApp_Preferences_LastKindleScreensLocation])
	{
		startLocation = [defaults URLForKey:USKindleScreensApp_Preferences_LastKindleScreensLocation];
		if([[NSFileManager defaultManager] isReadableFileAtPath:[startLocation path]])
			return startLocation;
	}
	else
		startLocation = [self attemptToDiscoverKindleVolume];
	return startLocation;
}

-(NSURL*)fixupUserChosenScreensaverURL:(NSURL*)u
{
	BOOL isDirectory = NO;
	
	if([[u path] isEqualToString:@"/Volumes/Kindle"])
	{
		if([[NSFileManager defaultManager] fileExistsAtPath:@"/Volumes/Kindle/linkss/screensavers" isDirectory:&isDirectory])
			if(isDirectory) return [NSURL fileURLWithPath:@"/Volumes/Kindle/linkss/screensavers"];
	}
	else if([[u path] isEqualToString:@"/Volumes/Kindle/linkss"])
	{
		if([[NSFileManager defaultManager] fileExistsAtPath:@"/Volumes/Kindle/linkss/screensavers" isDirectory:&isDirectory])
			if(isDirectory) return [NSURL fileURLWithPath:@"/Volumes/Kindle/linkss/screensavers"];		
	}
	return u;
}

-(void)loadImagesForKindleDirectoryURL
{	
    NSFileManager *f = [NSFileManager defaultManager];
	NSURL *startLocation = [self kindleSearchStartURL];
    
    BOOL isDirectory = NO;
	if(![f fileExistsAtPath:[startLocation path] isDirectory:&isDirectory])
		startLocation = nil;
	else if(!isDirectory)
		startLocation = nil;
	
	if(!startLocation)
		startLocation = [self userHomeDirectory];
    
	NSOpenPanel *p = [NSOpenPanel openPanel];
	[p setCanChooseFiles:NO];
	[p setCanChooseDirectories:YES];
	[p setAllowsMultipleSelection:NO];
	[p setTitle:@"Choose Kindle Screensaver location:"];
	[p setPrompt:@"Select"];
	[p setNameFieldLabel:@"Screensavers Directory"];
	[p setDirectoryURL:startLocation];
	
	self.showingOpenWindow = YES;
    
    if(![self.window isVisible])
        [self showWindow:self];
    
    [self enableAndDisableUI];
    
    void (^completionHandler)(NSInteger result) = 
        ^(NSInteger result){
            self.showingOpenWindow = NO;
            
            if(NSOKButton == result)
            {
                
                NSURL *r = [[p URLs] objectAtIndex:0];
                r = [self fixupUserChosenScreensaverURL:r];
                [defaults setURL:r forKey:USKindleScreensApp_Preferences_LastKindleScreensLocation];
                [defaults synchronize];
                
                kindleScreensDirectoryURL = r;
                
                [self willChangeValueForKey:@"hasImages"];
                [self.images loadImagesFromFolder:r];
                [self didChangeValueForKey:@"hasImages"];
                
                
                [self detectRandomFile];
                [self enableAndDisableUI];
                
            }
        };
    
    [p beginSheetModalForWindow:self.window 
              completionHandler:completionHandler];
}

-(IBAction)randomize:(id)sender
{
	[images randomize];
}

-(IBAction)renameFiles:(id)sender
{
	USAlert *a = [USAlert alertWithMessageText:@"Rename files on Kindle?" 
								 defaultButton:@"Rename"
							   alternateButton:@"Cancel"
								   otherButton:nil
							   informativeText:@"This action will rename the files on your Kindle so the Kindle will sort them in the same order that you've arranged them. This action cannot be undone.\n\nAre you sure you want to rename these files?"];
	
    void (^completionHandler)(NSInteger result) = 
        ^(NSInteger result) {
            if(NSAlertDefaultReturn == result)
            {
                NSInteger renameCount = [self.images renameImages];
                NSString *renameMessage;
                if(renameCount == 0)
                    renameMessage = @"No files were renamed.";
                else
                    renameMessage = [NSString stringWithFormat:@"%ld files were renamed.\n\nYou must reboot your Kindle before the changes take effect!", renameCount];
                
                [a dismissWindow];
                USAlert *finishAlert = [USAlert alertWithMessageText:@"Renaming is complete." defaultButton:@"Okay" alternateButton:nil otherButton:nil informativeText:renameMessage];
                [finishAlert beginSheetModalForWindow:self.window completionHandler:nil];
            }
        };
    
	[a beginSheetModalForWindow:self.window
			  completionHandler:completionHandler];
}

-(void)photoSelectionChanged:(NSNotification*)n
{
	USKindleImage *image = [n object];
	[self setSelectedImage:image];
    [self.imagePreview setImage:[image image]];
}

-(void)detectRandomFile
{
	if(!kindleScreensDirectoryURL) return;
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSURL *u = kindleScreensDirectoryURL;
	NSMutableArray *c = [NSMutableArray arrayWithArray:[u pathComponents]];
	
	if([c count] < 2) 
		return; 
	[c removeLastObject];
	
	u = [NSURL fileURLWithPathComponents:c];
	if(![[u lastPathComponent] isEqualToString:@"linkss"])
		return;
	
	BOOL isDirectory = NO;
	if([fm fileExistsAtPath:[u path] isDirectory:&isDirectory] && isDirectory)
	{
		u = [u URLByAppendingPathComponent:@"random"];
		if([fm fileExistsAtPath:[u path] isDirectory:NULL])
		{
			USAlert *a = [USAlert alertWithMessageText:@"\"Random\" file was detected!" 
										 defaultButton:@"Okay" 
									   alternateButton:nil
										   otherButton:nil
							 informativeText:@"The presence of a file named \"random\" in your Kindle's linkss directory puts the screensaver hack into Random Mode. The next time you reboot your Kindle, the order of your screensavers may be changed.\n\nCheck the documentation for your screensaver hack for more information."];
			[a beginSheetModalForWindow:self.window completionHandler:nil afterDelay:0];
		}
	}
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	if([self.window isVisible])
		return YES;
	
    [self showWindow:self];
    
	return NO;
}

-(IBAction)showWindow:(id)sender
{
	if(self.showingOpenWindow)
		return;
	
	[self.window makeKeyAndOrderFront:self];
}

-(IBAction)closeWindow:(id)sender
{
	NSWindow *key = [NSApp keyWindow];
	if(key)
	{
		if([key isVisible])
		{
			if([key isKindOfClass:[NSOpenPanel class]])
			{
				[(NSOpenPanel*)key cancel:self];
			}
			else
			{
				[key orderOut:self];				
			}
		}
	}
}

-(IBAction)locateKindleImagesDirectory:(id)sender
{
    if(self.showingOpenWindow)
        return;
    
    [self.images loadImagesFromFolder:nil];
    
    [self enableAndDisableUI];
    
    [self loadImagesForKindleDirectoryURL];
}

-(BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if(menuItem == renameMenu || menuItem == randomizeMenu)
        return (!showingOpenWindow && ([[imagesController arrangedObjects] count] > 0));        
    return YES;
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    return (!showingOpenWindow && ([[imagesController arrangedObjects] count] > 0));
}

-(void)enableAndDisableUI
{
    [toolbar validateVisibleItems];
}

@end
