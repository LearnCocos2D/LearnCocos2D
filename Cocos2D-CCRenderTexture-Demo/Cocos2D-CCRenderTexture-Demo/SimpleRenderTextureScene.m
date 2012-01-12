//
//  SimpleRenderTextureScene.m
//  Cocos2D-CCRenderTexture-Demo
//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "SimpleRenderTextureScene.h"

@implementation SimpleRenderTextureScene

-(id) init
{
	if ((self = [super init])) 
	{
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"CCRenderTexture: clear with color" fontName:@"Arial" fontSize:16];
		label.position = CGPointMake(240, 15);
		[self addChild:label];
		
		// create a simple rendertexture node
		CCRenderTexture* rtx = [CCRenderTexture renderTextureWithWidth:256 height:256];
		rtx.position = CGPointMake(240, 160);
		[self addChild:rtx z:0 tag:1];

		// keep updating the texture's color
		[self schedule:@selector(changeColor:) interval:0.5f];
	}
	return self;
}

-(void) changeColor:(ccTime)delta
{
	// clear (fill) the texture with a random color
	CCRenderTexture* rtx = (CCRenderTexture*)[self getChildByTag:1];
	[rtx clear:CCRANDOM_0_1()
			 g:CCRANDOM_0_1()
			 b:CCRANDOM_0_1()
			 a:CCRANDOM_0_1()];
}

@end
