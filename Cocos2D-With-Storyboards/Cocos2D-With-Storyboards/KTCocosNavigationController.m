//
//  KTCocosNavigationController.h
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

#import "KTCocosNavigationController.h"

// DO NOT MODIFY THIS CLASS DIRECTLY -- SUBCLASS IT!! See MyCocosNavigationController class.


// The navigation controller will remain in memory for the lifetime of the app.
// Thus it makes sense to handle all global events, including UIApplicationDelegate and memory warnings, here.
// It will also allow you to run the first, pop the last and replace the currently running scene
// when the CocosViewController storyboard is entered or exited.

@implementation KTCocosNavigationController

-(void) runFirstScene
{
	_isCocosViewActive = YES;
}

-(void) cocosViewDidLoadAgain
{
	_isCocosViewActive = YES;
}

-(void) cocosViewDidDisappear
{
	_isCocosViewActive = NO;
}

// iOS 6 only: use this method to programmatically override the Summary pane supported interface orientations setting.
-(NSUInteger) supportedInterfaceOrientations
{
	// default: support all orientations, mask as needed
	return UIInterfaceOrientationMaskAll;
}

// iOS 5 and earlier: return the supported orientations
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// support all orientations, change as needed
	return YES;
}

-(void) loadView
{
	// must call super loadView, otherwise you'll get the dreaded error:
	// "Applications are expected to have a root view controller at the end of application launch"
	[super loadView];
	
	[self registerApplicationDelegateNotifications];
}

-(void) registerApplicationDelegateNotifications
{
	// Capture certain UIApplicationDelegate messages to move the AppDelegate code here
	// Credit to Jerod Putman (Tiny Tim's) CCViewController, available here:
	// http://www.tinytimgames.com/2012/02/07/cocos2d-and-storyboards/
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationSignificantTimeChange:)
                                                 name:UIApplicationSignificantTimeChangeNotification
                                               object:nil];
}

-(void) unregisterApplicationDelegateNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationSignificantTimeChangeNotification object:nil];
}

-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// Note: the CocosNavigationController, if setup correctly in storyboards, will be the window's rootViewController:
	UIViewController* rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
	NSLog(@"rootVC: %@", rootVC);
	
	// This is just a reminder in case the user forgot to change the class of the Navigation controller in storyboards
	if ([rootVC isKindOfClass:[KTCocosNavigationController class]] == NO)
	{
		NSLog(@"WARNING: the storyboard's navigation controller does not exist or is not setup to use the CocosNavigationController class!");
	}
}

// This method will be called every time the cocos2d view size changes, or when the view receives the layoutSubviews message.
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	NSLog(@"directorDidReshapeProjection");
	if (director.runningScene == nil)
	{
		// It's important to run the first scene from here, to ensure the director's view sizes have been properly set in iOS 5.
		// Otherwise the first scene may be incorrectly sized and/or rotated on iOS 5.
		[self runFirstScene];
	}
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
	if (_isCocosViewActive)
	{
		[[CCDirector sharedDirector] pause];
	}
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	if (_isCocosViewActive)
	{
		[[CCDirector sharedDirector] resume];
	}
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
	if (_isCocosViewActive)
	{
		[[CCDirector sharedDirector] stopAnimation];
	}
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
	if (_isCocosViewActive)
	{
		[[CCDirector sharedDirector] startAnimation];
	}
}

- (void)applicationSignificantTimeChange:(NSNotification *)notification
{
	if (_isCocosViewActive)
	{
		[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
	}
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	// unregister and shutdown, goodbye!
	[self unregisterApplicationDelegateNotifications];
	[[CCDirector sharedDirector] end];
}

@end
