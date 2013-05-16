//
//  KTCocosViewController.m
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

#import "KTCocosViewController.h"
#import "KTCocosNavigationController.h"


// DO NOT MODIFY THIS CLASS DIRECTLY -- SUBCLASS IT!! See MyCocosViewController class.

// The CocosViewController (re-)creates the director and the director's OpenGL view.
// It also adds the director and its view to the controller/view hierarchy.

// Note: you should not implement memory warning code here, instead do that in the CocosNavigationController.
// The reason: memory warnings may occur while the cocos view controller isn't currently active,
// but the director and its caches might still be alive and retaining resources.

@implementation KTCocosViewController

// NOTE: in storyboards the initWithNibName:... method never runs! Put init code in loadView instead.
// See: http://developer.apple.com/library/ios/documentation/uikit/reference/UIViewController_Class/Reference/Reference#//apple_ref/occ/instm/UIViewController/initWithNibName:bundle:

-(void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	CCDirectorIOS* director = (CCDirectorIOS*)[CCDirector sharedDirector];
	
	// Get the CocosNavigationController and make it the director's delegate
	KTCocosNavigationController* navController = (KTCocosNavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
	NSAssert1([navController isKindOfClass:[KTCocosNavigationController class]], @"storyboards navigation controller (%@) is not of class CocosNavigationController", navController);
	[CCDirector sharedDirector].delegate = navController;
	
	// If the OpenGL view hasn't been created yet, create it once. Otherwise the existing GL view will be used.
	if (director.view == nil)
	{
		// CCGLView creation
		// viewWithFrame: size of the OpenGL view. For full screen use [_window bounds]
		//  - Possible values: any CGRect
		// pixelFormat: Format of the render buffer. Use RGBA8 for better color precision (eg: gradients). But it takes more memory and it is slower
		//	- Possible values: kEAGLColorFormatRGBA8, kEAGLColorFormatRGB565
		// depthFormat: Use stencil if you plan to use CCClippingNode. Use Depth if you plan to use 3D effects, like CCCamera or CCNode#vertexZ
		//  - Possible values: 0, GL_DEPTH_COMPONENT24_OES, GL_DEPTH24_STENCIL8_OES
		// sharegroup: OpenGL sharegroup. Useful if you want to share the same OpenGL context between different threads
		//  - Possible values: nil, or any valid EAGLSharegroup group
		// multiSampling: Whether or not to enable multisampling
		//  - Possible values: YES, NO
		// numberOfSamples: Only valid if multisampling is enabled
		//  - Possible values: 0 to glGetIntegerv(GL_MAX_SAMPLES_APPLE)
		CCGLView *glView = [CCGLView viewWithFrame:[UIApplication sharedApplication].keyWindow.bounds
									   pixelFormat:kEAGLColorFormatRGB565
									   depthFormat:0
								preserveBackbuffer:NO
										sharegroup:nil
									 multiSampling:NO
								   numberOfSamples:0];
		
		director.view = glView;
		
		[director setDisplayStats:YES];
		[director setAnimationInterval:1.0/60];
		[director setProjection:kCCDirectorProjection2D];
		[director enableRetinaDisplay:YES];
		
		// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
		// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
		// You can change anytime.
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
		
		// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
		// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
		// On iPad     : "-ipad", "-hd"
		// On iPhone HD: "-hd"
		CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
		[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
		[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
		[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
		[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
		
		// Assume that PVR images have premultiplied alpha
		[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	}
	
	// add the director and its view to the controller/view hierarchy
	[self addChildViewController:director];
	[self.view addSubview:director.view];
	[self.view sendSubviewToBack:director.view]; // just in case you have any overlay UIViews
	
	// you want multi-touch, right?
	self.view.multipleTouchEnabled = YES;
	
	// if there's already a running scene, we're re-visiting the existing scene and user may want to replace the scene
	if (director.runningScene)
	{
		[(KTCocosNavigationController*)director.delegate cocosViewDidLoadAgain];
	}
}

-(void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// inform the cocos nav controller, it may want to pop the running scene to reduce memory usage
	[(KTCocosNavigationController*)[CCDirector sharedDirector].delegate cocosViewDidDisappear];
}

#pragma mark autorotation

// Modal segues require these method to be implemented here as well, otherwise the cocos2d view won't be rotated.
// They're just passed along to the CocosNavigationController so they need only be customized in one class.

-(NSUInteger) supportedInterfaceOrientations
{
	// just return whatever the CocosNavigationController allows
	return [(KTCocosNavigationController*)[CCDirector sharedDirector].delegate supportedInterfaceOrientations];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// just return whatever the CocosNavigationController allows
	return [[CCDirector sharedDirector].delegate shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end
