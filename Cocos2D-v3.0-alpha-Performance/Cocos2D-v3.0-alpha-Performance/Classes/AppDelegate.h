//
//  AppDelegate.h
//  Cocos2D-v3.0-alpha-Performance
//
//  Created by Steffen Itterheim on 12/12/13.
//  Copyright Steffen Itterheim 2013. All rights reserved.
//
// -----------------------------------------------------------------------

#import <UIKit/UIKit.h>
#import "cocos2d.h"

// -----------------------------------------------------------------------

// Added only for iOS 6 support
@interface MyNavigationController : UINavigationController <CCDirectorDelegate>
@end

// -----------------------------------------------------------------------

@interface AppController : NSObject <UIApplicationDelegate>

// -----------------------------------------------------------------------

@property (nonatomic, retain) UIWindow      *window;
@property (readonly) MyNavigationController *navController;
@property (weak, readonly) CCDirectorIOS    *director;

// -----------------------------------------------------------------------
@end