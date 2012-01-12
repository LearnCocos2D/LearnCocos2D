//
//  CCSprite+Category.m
//  Cocos2D-CCRenderTexture-Demo
//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "CCSprite+Category.h"

@implementation CCSprite (RenderTextureCategory)

+(id) spriteWithRenderTexture:(CCRenderTexture*)rtx
{
	CCSprite* sprite = [CCSprite spriteWithTexture:rtx.sprite.texture];
	sprite.scaleY = -1;
	return sprite;
}

@end
