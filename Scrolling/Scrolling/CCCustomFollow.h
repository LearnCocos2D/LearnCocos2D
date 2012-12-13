//
//  CCCustomFollow.h
//  Cocos2D-Scrolling
//
//  Copyright Steffen Itterheim 2012. Distributed under MIT License.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCCustomFollow : CCFollow
{
    CGPoint currentPos;
	CGPoint previousTargetPos;
	BOOL isCurrentPosValid;
}

@end
