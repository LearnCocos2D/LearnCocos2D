//
//  SketchRenderTextureScene.h
//  Cocos2D-CCRenderTexture-Demo
//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "cocos2d.h"

@interface SketchRenderTextureScene : CCScene <CCTargetedTouchDelegate>
{
	CCSprite* brush;
	NSMutableArray* touches;
}

@end
