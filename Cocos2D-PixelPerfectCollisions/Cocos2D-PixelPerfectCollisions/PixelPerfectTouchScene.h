//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "cocos2d.h"
#import "KKPixelMaskSprite.h"

@interface PixelPerfectTouchScene : CCScene

@end

@interface PixelPerfectTouchLayer : CCLayer
{
	CCDirector* director;
	KKPixelMaskSprite* spriteA;
	KKPixelMaskSprite* spriteB;
	CCLabelTTF* feedback;
}

@end
