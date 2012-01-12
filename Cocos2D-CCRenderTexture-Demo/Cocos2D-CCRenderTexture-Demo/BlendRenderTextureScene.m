//
//  BlendRenderTextureScene.m
//  Cocos2D-CCRenderTexture-Demo
//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "BlendRenderTextureScene.h"
#import "CCScreenshot.h"

@implementation BlendRenderTextureScene

// helper function to add some rotating sprites and labels
-(CCSprite*) addIconSpriteTo:(CCNode*)node
{
	CCSprite* icon = [CCSprite spriteWithFile:@"Icon.png"];
	icon.position = CGPointMake(70, 70);
	icon.color = ccc3(CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255);
	[node addChild:icon];
	
	id rotate = [CCRotateBy actionWithDuration:20 angle:360];
	id repeat = [CCRepeatForever actionWithAction:rotate];
	[icon runAction:repeat];
	
	CCLabelTTF* label = [CCLabelTTF labelWithString:@"Wwiiiiiiiiihhh!" fontName:@"Helvetica" fontSize:24];
	label.rotation = CCRANDOM_0_1() * 360;
	label.position = CGPointMake(CCRANDOM_0_1() * 200 - 100, CCRANDOM_0_1() * 200 - 100);
	label.color = ccc3(CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255);
	[icon addChild:label];
	
	return icon;
}

-(void) createBackground
{
	CGSize winSize = [CCDirector sharedDirector].winSize;
	CCSprite* bg = [CCSprite spriteWithFile:@"Default.png"];
	bg.rotation = 87;
	bg.anchorPoint = CGPointZero;
	bg.position = CGPointMake(-(winSize.width / 2), winSize.height + winSize.height / 2);
	bg.flipY = YES;
	bg.scale = 2 * CC_CONTENT_SCALE_FACTOR();
	[self addChild:bg];
	[bg.texture setAliasTexParameters];
	
	{
		float duration = 20;
		id scale1 = [CCScaleTo actionWithDuration:duration scale:bg.scale * 1.05f];
		id scale2 = [CCScaleTo actionWithDuration:duration scale:bg.scale * 0.95f];
		id easeScale1 = [CCEaseSineInOut actionWithAction:scale1];
		id easeScale2 = [CCEaseSineInOut actionWithAction:scale2];
		id sequence = [CCSequence actions:easeScale1, easeScale2, nil];
		id repeat = [CCRepeatForever actionWithAction:sequence];
		[bg runAction:repeat];
		
		duration = 3;
		float angle = 0.5f;
		id rotate1 = [CCRotateBy actionWithDuration:duration angle:-angle];
		id rotate2 = [CCRotateBy actionWithDuration:duration angle:angle];
		id easeRotate1 = [CCEaseBackInOut actionWithAction:rotate1];
		id easeRotate2 = [CCEaseBackInOut actionWithAction:rotate2];
		id sequence2 = [CCSequence actions:easeRotate1, easeRotate2, nil];
		id repeat2 = [CCRepeatForever actionWithAction:sequence2];
		[bg runAction:repeat2];
	}
}

-(void) createBigLabel
{
	CCLabelTTF* label = [CCLabelTTF labelWithString:@"Hello Scene with Nodes" fontName:@"Marker Felt" fontSize:56];
	label.color = ccGREEN;
	label.rotation = 20;
	label.position = CGPointMake(240, 160);
	[self addChild:label];
	
	{
		float duration = 3;
		id tint1 = [CCTintTo actionWithDuration:duration red:255 green:0 blue:0];
		id tint2 = [CCTintTo actionWithDuration:duration red:255 green:255 blue:0];
		id tint3 = [CCTintTo actionWithDuration:duration red:0 green:255 blue:0];
		id tint4 = [CCTintTo actionWithDuration:duration red:0 green:255 blue:255];
		id tint5 = [CCTintTo actionWithDuration:duration red:0 green:0 blue:255];
		id tint6 = [CCTintTo actionWithDuration:duration red:255 green:0 blue:255];
		id sequence = [CCSequence actions:tint1, tint2, tint3, tint4, tint5, tint6, nil];
		id repeat = [CCRepeatForever actionWithAction:sequence];
		[label runAction:repeat];
	}
}

-(id) init
{
	if ((self = [super init])) 
	{
		CGSize winSize = [CCDirector sharedDirector].winSize;
		rtx = [[CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height] retain];

		// just adding some nodes for a "pretend" scene with nodes in it

		[self createBackground];
		
		CCSprite* icon = [self addIconSpriteTo:self];
		icon.position = CGPointMake(240, 160);
		icon.tag = 10;
		
		// Note: more than about 11/12 and you'll start seeing OpenGL swapbuffer errors!
		for (int i = 0; i < 10; i++)
		{
			icon = [self addIconSpriteTo:icon];
		}

		[self createBigLabel];
		
		CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"Render OpenGL onto CCRenderTexture" fontName:@"Arial" fontSize:16];
		label2.position = CGPointMake(240, 15);
		[self addChild:label2];
		
		[self schedule:@selector(takeScreenshotWithRenderTexture:) interval:2.345f];
	}
	return self;
}

-(void) removeScreenshotSprite:(CCNode*)node
{
	[node removeFromParentAndCleanup:YES];
}

-(void) takeScreenshotWithRenderTexture:(ccTime)delta
{
	if (takeScreenshot == NO)
	{
		// defer the screenshot until after the draw method has rendered the screen
		takeScreenshot = YES;
	}
	else
	{
		takeScreenshot = NO;
		CGSize winSize = [CCDirector sharedDirector].winSize;

		// take the screenshot by rendering the scene into the render texture
		[rtx beginWithClear:0.0f g:0.0f b:0.0f a:0.0f];

		// this is just a simple example of drawing regular OpenGL stuff onto the render texture
		glLineWidth(2);
		glColor4f(1.0f, 0.0f, 0.0f, 0.6f);
		for (int i = 0; i < winSize.height; i += 5)
		{
			ccDrawLine(CGPointMake(0, i), CGPointMake(winSize.width, i));
		}
		
		glColor4f(1.0f, 0.0f, 0.0f, 0.5f);
		glLineWidth(4);
		ccDrawQuadBezier(CGPointZero, CGPointMake(winSize.width, 0), CGPointMake(winSize.width, winSize.height), 12);
		ccDrawQuadBezier(CGPointZero, CGPointMake(0, winSize.height), CGPointMake(winSize.width, winSize.height), 12);

		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		glLineWidth(1);

		// draw only the icons with a red color mask
		glColorMask(1.0f, 0.0f, 0.0f, 1.0f);
		CCSprite* icon = (CCSprite*)[self getChildByTag:10];
		[icon visit];
		glColorMask(1.0f, 1.0f, 1.0f, 1.0f);
		
		[rtx end];
		
		
		// add the sprite from the newly created screenshot as proof that it worked
		CCSprite* screenshotSprite = [CCSprite spriteWithTexture:rtx.sprite.texture];
		screenshotSprite.scaleY = -1;
		screenshotSprite.position = CGPointMake(winSize.width / 2, winSize.height / 2);
		[self addChild:screenshotSprite];
		
		
		// run an action animation for kicks ...
		float duration = 1.7f;
		id rotate = [CCRotateBy actionWithDuration:duration * 2.0f angle:150];
		id easeRotate = [CCEaseExponentialIn actionWithAction:rotate];
		[screenshotSprite runAction:easeRotate];
		
		id move = [CCMoveTo actionWithDuration:duration * 1.5f position:CGPointMake(-winSize.width, -winSize.height * 3)];
		id easeMove = [CCEaseExponentialIn actionWithAction:move];
		[screenshotSprite runAction:easeMove];
		
		id fade = [CCFadeOut actionWithDuration:duration * 2.0f];
		id callback = [CCCallFuncN actionWithTarget:self selector:@selector(removeScreenshotSprite:)];
		id sequence = [CCSequence actions:fade, callback, nil];
		[screenshotSprite runAction:sequence];
	}
}

-(void) draw
{
	[super draw];
	
	// to avoid a small "jump" of moving objects the screenshot should be taken AFTER the draw method
	if (takeScreenshot) 
	{
		[self takeScreenshotWithRenderTexture:0];
	}
}

@end
