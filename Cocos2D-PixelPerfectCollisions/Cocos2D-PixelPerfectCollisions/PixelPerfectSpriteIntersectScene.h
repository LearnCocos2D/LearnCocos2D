//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "cocos2d.h"
#import "KKPixelMaskSprite.h"

@interface PixelPerfectSpriteIntersectScene : CCScene

@end

@interface PixelPerfectSpriteIntersectLayer : CCLayer
{
	CCDirector* director;
	KKPixelMaskSprite* spriteA;
	KKPixelMaskSprite* spriteB;
	CCLabelTTF* feedback;
}

@end
