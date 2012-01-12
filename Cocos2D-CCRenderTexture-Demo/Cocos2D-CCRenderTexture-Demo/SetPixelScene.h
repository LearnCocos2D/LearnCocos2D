//
//  SetPixelScene.h
//  Cocos2D-CCRenderTexture-Demo
//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "cocos2d.h"
#import "CCTexture2DMutable.h"

typedef enum
{
	ColorCycleRed,
	ColorCycleGreen,
	ColorCycleBlue,
	
	ColorCycle_End
} ColorCycleMode;

@interface SetPixelScene : CCScene
{
	void* textureData;
	CCSprite* sprite;
	ColorCycleMode colorCycleMode;
}

@end
