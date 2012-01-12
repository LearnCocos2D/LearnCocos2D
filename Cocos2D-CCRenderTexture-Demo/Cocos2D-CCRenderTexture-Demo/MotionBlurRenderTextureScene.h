//
//  MotionBlurRenderTextureScene.h
//  Cocos2D-CCRenderTexture-Demo
//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "cocos2d.h"

@interface MotionBlurRenderTextureScene : CCScene
{
	NSMutableArray* renderTextures;
	NSUInteger currentRenderTextureIndex;
	BOOL clearRenderTexture;
}

@end
