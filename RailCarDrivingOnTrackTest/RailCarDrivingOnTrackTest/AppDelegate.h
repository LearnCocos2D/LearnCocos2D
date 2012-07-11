//
//  AppDelegate.h
//  RailCarDrivingOnTrackTest
//
//  Created by Steffen Itterheim on 11.07.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

@interface RailCarDrivingOnTrackTestAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	CCGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet CCGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
