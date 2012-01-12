//
//  NodeRenderTextureScene.m
//  Cocos2D-CCRenderTexture-Demo
//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "NodeRenderTextureScene.h"

@interface NodeRenderTextureScene (PrivateMethods)
-(void) renderNodesOntoTexture:(ccTime)delta;
@end

@implementation NodeRenderTextureScene

-(id) init
{
	if ((self = [super init])) 
	{
		glClearColor(1, 0, 1, 1);
	
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"CCRenderTexture node rendering / CCSprite using render texture" fontName:@"Arial" fontSize:16];
		label.position = CGPointMake(240, 40);
		[self addChild:label];
		
		// create a simple rendertexture node and clear it with the color white
		CCRenderTexture* rtx = [CCRenderTexture renderTextureWithWidth:200
																height:200 
														   pixelFormat:kCCTexture2DPixelFormat_RGBA4444];
		rtx.position = CGPointMake(120, 160);
		[self addChild:rtx z:0 tag:1];
		
		// render some nodes onto the rendertexture
		[self renderNodesOntoTexture:0];
		[self schedule:@selector(renderNodesOntoTexture:) interval:1];
		
		
		// create a separate sprite using the rendertexture
		// even though this sprite is separate it will be updated whenever the rendertexture contents change
		CCSprite* spriteWithRTX = [CCSprite spriteWithTexture:rtx.sprite.texture];
		spriteWithRTX.position = CGPointMake(360, 160);
		// since the texture is upside down, the sprite needs to be flipped to correct this:
		spriteWithRTX.scaleY = -1;
		[self addChild:spriteWithRTX];
	}
	return self;
}

-(int) rndColor
{
	return CCRANDOM_0_1() * 220 + 35;
}

-(void) renderNodesOntoTexture:(ccTime)delta
{
	// clear (fill) the texture with a random color
	CCRenderTexture* rtx = (CCRenderTexture*)[self getChildByTag:1];
	
	// clear the texture with white color and random alpha, and begin rendering
	// Notice that the rendertexture seemingly ignores alpha, 
	// whereas sprites created from the rendertexture render with alpha!
	[rtx beginWithClear:1 g:1 b:1 a:CCRANDOM_0_1()];
	
	
	// Create a new sprite
	// the sprite isn't added as child on purpose because that's not necessary!
	CCSprite* sprite = [CCSprite spriteWithFile:@"Icon.png"];
	sprite.scale = 1.0f + CCRANDOM_0_1();
	sprite.rotation = CCRANDOM_0_1() * 360;
	sprite.color = ccc3([self rndColor], [self rndColor], [self rndColor]);
	
	// the node's 0,0 position is at the lower-left corner of the render texture
	// this centers the node on the render texture:
	sprite.position = CGPointMake(rtx.sprite.contentSize.width * rtx.sprite.anchorPoint.x, 
								  rtx.sprite.contentSize.height * rtx.sprite.anchorPoint.y);

	// visit will render the sprite
	[sprite visit];
	
	
	// render the same sprite again, at different position without filtering and other properties
	sprite.color = ccc3([self rndColor], [self rndColor], [self rndColor]);
	sprite.rotation = -70;
	sprite.scale = 4;
	sprite.position = CGPointMake(-45, 135);
	
	// turn off filtering
	[sprite.texture setAliasTexParameters];
	// render sprite without filtering
	[sprite visit];
	// turn filtering back on because not doing so would leave filtering disabled for all textures
	[sprite.texture setAntiAliasTexParameters];
	
	
	// also render a label onto the texture
	CCLabelTTF* label = [CCLabelTTF labelWithString:@"Hello RenderTexture" fontName:@"Helvetica" fontSize:20];
	label.anchorPoint = CGPointMake(0, 0);
	CGPoint labelPos = label.position;
	
	// render the label multiple times with different colors
	for (int i = 0; i < 10; i++)
	{
		label.color = ccc3([self rndColor], [self rndColor], [self rndColor]);
		[label visit];
		
		label.scale -= 0.1f;
		labelPos.y += label.contentSize.height * label.scaleY;
		label.position = labelPos;
	}
	
	
	// end rendering
	[rtx end];
}

@end
