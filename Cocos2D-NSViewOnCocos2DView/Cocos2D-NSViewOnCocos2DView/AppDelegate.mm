//
//  AppDelegate.mm
//  Cocos2D-NSViewOnCocos2DView
//
//  Created by Steffen Itterheim on 17.04.13.
//  Copyright Steffen Itterheim 2013. All rights reserved.
//


#import "AppDelegate.h"
#import "HelloWorldLayer.h"

@implementation OverlayAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	// enable FPS and SPF
	[director setDisplayStats:YES];
	
	// connect the OpenGL view with the director
	[director setView:_glView];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_AutoScale];
	
	// Enable "moving" mouse event. Default no.
	[_window setAcceptsMouseMovedEvents:NO];
	
	// Center main window
	[_window center];

	CCScene *scene = [CCScene node];
	[scene addChild:[HelloWorldLayer node]];
	
	[director runWithScene:scene];
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

// add the overridden overlayWindow accessor (getter) method
-(NSWindow*) overlayWindow
{
	// if the overlay doesn't exist yet, create it
	if (_overlayWindow == nil)
	{
		_overlayWindow = [[NSWindow alloc] initWithContentRect:_window.frame
													 styleMask:NSBorderlessWindowMask
													   backing:NSBackingStoreBuffered
														 defer:NO];
		NSLog(@"Created overlay window: %@", _overlayWindow);

		// make sure the window is "see-through" and has no shadow
		[_overlayWindow setBackgroundColor:[NSColor clearColor]];
		[_overlayWindow setOpaque:NO];
		[_overlayWindow setHasShadow:NO];
		
		// the window also needs a contentView - just an empty NSView spanning the entire window
		NSView* contentView = [[NSView alloc] initWithFrame:_window.frame];
		[_overlayWindow setContentView:contentView];
		
		// add the overlay window as child window and
		// make AppDelegate (self) the window's NSWindowDelegate object
		[_window addChildWindow:_overlayWindow ordered:NSWindowAbove];
		_window.delegate = self;
	}
	
	return _overlayWindow;
}

// add the windowWillClose message of NSWindowDelegate protocol
-(void) windowWillClose:(NSNotification*)notification
{
	NSLog(@"Closing window: %@", [notification object]);
	
	// check if it's the main window that's being closed
	if ([notification object] == _window)
	{
		// if so, close the overlay window to prevent the app from "hanging"
		// not closing the overlay window would mean there'd still be an open window (though invisible)
		// and therefore the terminate event "when last window closed" would never fire
		[_overlayWindow close];

		// in addition, it is a good idea to stop director here to prevent OpenGL errors being logged on shutdown
		[[CCDirector sharedDirector] stopAnimation];
	}
}

// add applicationWillTerminate to see if the app is actually shutting down (dealloc never gets called!)
-(void) applicationWillTerminate:(NSNotification *)notification
{
	NSLog(@"teeeeerminate, good times, come on!");
}

+(NSView*) overlayWindowContentView
{
	OverlayAppDelegate* appDelegate = (OverlayAppDelegate*)[NSApplication sharedApplication].delegate;
	return appDelegate.overlayWindow.contentView;
}

+(void) addSubview:(NSView *)view
{
	[[self overlayWindowContentView] addSubview:view];
}

+(void) removeAllSubviews
{
	// By using reverseObjectEnumerator the subviews collection can be modified while enumerating it
	// because it's legal to remove the last item of an array during enumeration (ie this "unrolls" the array from back to front)
	NSArray* subviews = [self overlayWindowContentView].subviews;
	for (NSView* view in [subviews reverseObjectEnumerator])
	{
		[view removeFromSuperview];
	}
}

@end
