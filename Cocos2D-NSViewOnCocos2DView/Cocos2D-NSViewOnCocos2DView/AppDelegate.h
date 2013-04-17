//
//  AppDelegate.h
//  Cocos2D-NSViewOnCocos2DView
//
//  Created by Steffen Itterheim on 17.04.13.
//  Copyright Steffen Itterheim 2013. All rights reserved.
//

#import "cocos2d.h"

// add the NSWindowDelegate protocol
@interface OverlayAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
{
	@private
	// add the _overlayWindow ivar
	NSWindow* _overlayWindow;
}

// add the overlayWindow property
@property (nonatomic, readonly) IBOutlet NSWindow* overlayWindow;

// helper
+(NSView*) overlayWindowContentView;
+(void) addSubview:(NSView*)view;
+(void) removeAllSubviews;


@property (nonatomic) IBOutlet NSWindow	*window;
@property (nonatomic) IBOutlet CCGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
