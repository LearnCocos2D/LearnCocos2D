//
//  MyCocosNavigationController.m
//  Cocos2D-With-Storyboards
//
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MyCocosNavigationController.h"
#import "IntroLayer.h"
#import "HelloWorldLayer.h"

// This is where you would add your custom code for the Cocos2D storyboard.
// Consider creating a new subclass for every cocos2d storyboard that needs to run non-trivial custom code.

@implementation MyCocosNavigationController

#pragma mark run the very first scene (change to scene you want to launch)

// This message runs every time the CocosViewController storyboard is visited and the director has NO running scene.
// This message will also be sent if you popScene in cocosViewDidDisappear because that'll "end" the director.
-(void) runFirstScene
{
	[super runFirstScene]; // must call super
	
	[[CCDirector sharedDirector] runWithScene:[IntroLayer scene]];
}

// This message is sent by CocosViewController every time its storyboard is visited and the director HAS a running scene.
-(void) cocosViewDidLoadAgain
{
	[super cocosViewDidLoadAgain]; // must call super
	
	// Uncomment this line to change to a different or reload a scene whenever the cocos2d storyboard is entered.
	//[[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

// This message is sent by CocosViewController when its storyboard exited.
-(void) cocosViewDidDisappear
{
	[super cocosViewDidDisappear]; // must call super
	
	// Don't uncomment the two lines below if you want to:
	// a) return to the previously running scene in the state you left it
	// b) want to switch back to cocos2d as quickly as possible (all resources still being cached)
	// c) you have no reason to wipe all memory because the storyboards side of your app simply doesn't consume much memory
	
	// Ensure all additionally pushed scenes are popped, remaining only one scene on the stack, then pops the
	// remaining running scene - this will automatically and properly "end" the director and purge all caches!
	//[[CCDirector sharedDirector] popToRootScene];
	//[[CCDirector sharedDirector] popScene]; // this will "end" the director
	
	// DO NOT CALL CCDIRECTOR END MANUALLY HERE!! Uncomment the above lines and leave it up to cocos2d to end itself!
}

#pragma mark Autorotation overrides (uncomment & modify as needed)

// iOS 6 only: use this method to programmatically override the Summary pane supported interface orientations setting.
-(NSUInteger) supportedInterfaceOrientations
{
	// use defaults (allow all orientations), replace as needed
	return [super supportedInterfaceOrientations];
}

// iOS 5 and earlier: return the supported orientations
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// use defaults (allow all orientations), replace as needed
	return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark Memory Warning (Replace with more intelligent 'purge only unused resources' code)

-(void) didReceiveMemoryWarning
{
	// This is rarely a good idea, but it's cocos2d's brute-force default:
	[[CCDirector sharedDirector] purgeCachedData];
	
	// The better solution instead of purging is to *know* what resources you can free, and free only those.
	// Keep in mind that textures consume almost all of the memory, so focus on uncaching currently unused textures
	// sprite frames. Note that purgeCachedData does NOT purge the sprite frame cache!
	// You can practically ignore all the other caches because they contribute so little to overall memory usage.
	
	// Also consider that you may receive memory warnings WHILE you are loading textures, at which time cocos2d
	// will still consider them "unused" and purging caches or removing unused textures may remove exactly those
	// textures you just recently preloaded! This will cause the textures to be loaded again, but only when
	// they're actually being used as if they had never been preloaded.
}


#pragma mark UIApplicationDelegate methods

// NOTE: these UIApplicationDelegate notifications are only received while the cocos2d storyboard view
// is presented. When you segued away from the cocos2d view, these messages will not be sent.
// For tasks that need to be handled always, regardless of cocos2d being presented or not, use the
// notifications in the AppDelegate class!

- (void)applicationWillResignActive:(NSNotification *)notification
{
	// pauses director
	[super applicationWillResignActive:notification];
	
	// perform additional tasks before suspending
	// NOTE: this method will only run when cocos2d's storyboard is presented!
	// Use AppDelegate implementation of this method if you need to run this code globally.
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	// resumes director
    [super applicationDidBecomeActive:notification];
	
	// perform additional tasks after becoming active again
	// NOTE: this method will only run when cocos2d's storyboard is presented!
	// Use AppDelegate implementation of this method if you need to run this code globally.
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
	// calls director stopAnimation
	[super applicationDidEnterBackground:notification];
	
	// perform additional tasks after entering background
	// NOTE: this method will only run when cocos2d's storyboard is presented!
	// Use AppDelegate implementation of this method if you need to run this code globally.
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
	// calls director startAnimation
    [super applicationWillEnterForeground:notification];
	
	// perform additional tasks before entering foreground
	// NOTE: this method will only run when cocos2d's storyboard is presented!
	// Use AppDelegate implementation of this method if you need to run this code globally.
}

- (void)applicationSignificantTimeChange:(NSNotification *)notification
{
	// calls director setNextDeltaTimeZero
    [super applicationSignificantTimeChange:notification];
	
	// perform additional tasks when there's a significant time change
	// NOTE: this method will only run when cocos2d's storyboard is presented!
	// Use AppDelegate implementation of this method if you need to run this code globally.
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[super applicationWillTerminate:notification];
	
	// perform custom shutdown code here ...
	// NOTE: this method will only run when cocos2d's storyboard is presented!
	// Use AppDelegate implementation of this method if you need to run this code globally.
}

@end
