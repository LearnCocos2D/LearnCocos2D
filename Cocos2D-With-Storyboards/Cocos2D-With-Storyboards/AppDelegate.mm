//
//  AppDelegate.mm
//  Cocos2D-With-Storyboards
//
//  Created by Steffen Itterheim on 16.05.13.
//  Copyright Steffen Itterheim 2013. All rights reserved.
//

#import "AppDelegate.h"


// IMPORTANT: the AppDelegate (AppController, sheesh cocos, really?!) now longer concerns itself with Cocos2D stuff.
// The necessary UIApplicationDelegate messages related to cocos2d can be received and overridden in your
// CocosNavigationController subclass. All other notification code that is independent of cocos2d, such as
// synchronizing user defaults upon termination for example, should be handled here!


@implementation AppController

- (void)applicationWillResignActive:(NSNotification *)notification
{
	// perform additional tasks before suspending
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	// perform additional tasks after becoming active again
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
	// perform additional tasks after entering background
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
	// perform additional tasks before entering foreground
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	// perform custom shutdown code here ...
}

@end
