//
//  MotionBlurRenderTextureScene.m
//  Cocos2D-CCRenderTexture-Demo
//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "MotionBlurRenderTextureScene.h"
#import "CCSprite+Category.h"

@implementation MotionBlurRenderTextureScene

// helper function to add some rotating sprites and labels
-(CCSprite*) addIconSpriteTo:(CCNode*)node
{
	CCSprite* icon = [CCSprite spriteWithFile:@"Icon.png"];
	icon.position = CGPointMake(70, 70);
	icon.color = ccc3(CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255);
	[node addChild:icon];
	
	id rotate = [CCRotateBy actionWithDuration:16 angle:360];
	id repeat = [CCRepeatForever actionWithAction:rotate];
	[icon runAction:repeat];
	
	CCLabelTTF* label = [CCLabelTTF labelWithString:@"Wwiiiiiiiiihhh!" fontName:@"Helvetica" fontSize:24];
	label.rotation = CCRANDOM_0_1() * 360;
	label.position = CGPointMake(CCRANDOM_0_1() * 200 - 100, CCRANDOM_0_1() * 200 - 100);
	label.color = ccc3(CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255);
	[icon addChild:label];
	
	return icon;
}

// higher value = more blur but slower performance
const int kRenderTextureCount = 4;

-(void) setupRenderTextures
{
	CGSize winSize = [CCDirector sharedDirector].winSize;
	renderTextures = [[NSMutableArray arrayWithCapacity:kRenderTextureCount] retain];
	
	for (int i = 0; i < kRenderTextureCount; i++)
	{
		CCRenderTexture* rtx = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
		rtx.position = CGPointMake(winSize.width / 2, winSize.height / 2);
		
		CCSprite* renderSprite = [CCSprite spriteWithRenderTexture:rtx];
		renderSprite.position = rtx.position;
		
		[self addChild:renderSprite z:100 + i];
		rtx.userData = renderSprite;
		[renderTextures addObject:rtx];
	}
}

-(id) init
{
	if ((self = [super init])) 
	{
		[self setupRenderTextures];
		
		// just adding some nodes for a "pretend" scene with nodes in it
		 
		CCSprite* icon = [self addIconSpriteTo:self];
		icon.position = CGPointMake(240, 160);
		icon.tag = 10;
		
		// Note: more than about 11/12 and you'll start seeing OpenGL swapbuffer errors!
		for (int i = 0; i < 10; i++)
		{
			icon = [self addIconSpriteTo:icon];
		}
		
		CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"Fullscreen motion-blur with CCRenderTexture" fontName:@"Arial" fontSize:16];
		label2.position = CGPointMake(240, 15);
		[self addChild:label2];
		
		clearRenderTexture = YES;
		[self schedule:@selector(changeRenderTextureClearMode:) interval:20];
	}
	return self;
}

-(void) cleanup
{
	[renderTextures release];
	renderTextures = nil;
}

-(void) changeRenderTextureClearMode:(ccTime)delta
{
	clearRenderTexture = !clearRenderTexture;
	for (CCRenderTexture* rtx in renderTextures)
	{
		[rtx clear:1 g:1 b:1 a:0];
	}
}

-(void) selectNextRenderTexture
{
	currentRenderTextureIndex++;
	if (currentRenderTextureIndex >= kRenderTextureCount)
	{
		currentRenderTextureIndex = 0;
	}
}

-(void) visit
{
	// force manual drawing by not calling super visit ...
	//[super visit];

	// render into next rendertexture
	CCRenderTexture* rtx = [renderTextures objectAtIndex:currentRenderTextureIndex];

	if (clearRenderTexture)
	{
		[rtx beginWithClear:0 g:0 b:0 a:0];
	}
	else
	{
		[rtx begin];
	}
	
	CCNode* node;
	CCARRAY_FOREACH([self children], node)
	{
		if (node.tag == 10)
		{
			[node visit];
		}
	}
	[rtx end];
	
	// reorder the render textures so that the most recently rendered texture is drawn last
	[self selectNextRenderTexture];
	int index = currentRenderTextureIndex;
	for (int i = 0; i < kRenderTextureCount; i++)
	{
		CCRenderTexture* rtx = (CCRenderTexture*)[renderTextures objectAtIndex:index];
		CCSprite* renderSprite = (CCSprite*)rtx.userData;
		renderSprite.opacity = (255.0f / kRenderTextureCount) * (i + 1);
		[self reorderChild:renderSprite z:100 + i];
		[self selectNextRenderTexture];
		
		index++;
		if (index >= kRenderTextureCount) {
			index = 0;
		}
	}
	
	// draw any remaining nodes
	CCARRAY_FOREACH([self children], node)
	{
		if (node.tag != 10)
		{
			[node visit];
		}
	}
}


@end
