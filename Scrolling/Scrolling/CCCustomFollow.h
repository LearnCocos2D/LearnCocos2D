//
//  CCCustomFollow.h
//  Cocos2D-Scrolling
//
//  Created by Steffen Itterheim on 13.12.12.
//  Copyright 2012 Steffen Itterheim. All rights reserved.
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
