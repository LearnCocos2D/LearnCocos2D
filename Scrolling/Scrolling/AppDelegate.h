//
//  AppDelegate.h
//  Scrolling
//
//  Copyright Steffen Itterheim 2012. Distributed under MIT License.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;

	__weak CCDirectorIOS	* director_;							// weak ref
}

@property (nonatomic, strong) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (weak, readonly) CCDirectorIOS *director;

@end
