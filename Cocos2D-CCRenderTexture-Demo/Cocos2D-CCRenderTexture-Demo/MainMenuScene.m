//
//  MainMenuScene.m
//  Cocos2D-CCRenderTexture-Demo
//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "MainMenuScene.h"
#import "ReturnToMainMenuNode.h"
#import "SetPixelScene.h"
#import "SimpleRenderTextureScene.h"
#import "NodeRenderTextureScene.h"
#import "ScreenshotRenderTextureScene.h"
#import "SketchRenderTextureScene.h"
#import "MotionBlurRenderTextureScene.h"
#import "BlendRenderTextureScene.h"
#import "CCScreenshot.h"

@interface MainMenuScene (PrivateMethods)
-(void) loadBackground;
@end

@implementation MainMenuScene

-(id) init
{
	if ((self = [super init]))
	{
		glClearColor(0.2f, 0.0f, 0.1f, 1);
		
		[self loadBackground];

		CCMenu* menu = [CCMenu menuWithItems:nil];
		[self addChild:menu];
		
		NSString* fontName = @"Arial";
		CGFloat fontSize = 28;

		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"Simple CCRenderTexture" fontName:fontName fontSize:fontSize];
			CCMenuItem* item = [CCMenuItemLabel itemWithLabel:label block:^(id sender)
			{
				CCScene* scene = [SimpleRenderTextureScene node];
				[ReturnToMainMenuNode returnNodeWithParent:scene];
				[[CCDirector sharedDirector] replaceScene:scene];
			}];
			[menu addChild:item];
		}
		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"Draw Nodes on CCRenderTexture" fontName:fontName fontSize:fontSize];
			CCMenuItem* item = [CCMenuItemLabel itemWithLabel:label block:^(id sender)
			{
				CCScene* scene = [NodeRenderTextureScene node];
				[ReturnToMainMenuNode returnNodeWithParent:scene];
				[[CCDirector sharedDirector] replaceScene:scene];
			}];
			[menu addChild:item];
		}
		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"OpenGL on CCRenderTexture" fontName:fontName fontSize:fontSize];
			CCMenuItem* item = [CCMenuItemLabel itemWithLabel:label block:^(id sender)
			{
				CCScene* scene = [BlendRenderTextureScene node];
				[ReturnToMainMenuNode returnNodeWithParent:scene];
				[[CCDirector sharedDirector] replaceScene:scene];
			}];
			[menu addChild:item];
		}
		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"Screenshot with CCRenderTexture" fontName:fontName fontSize:fontSize];
			CCMenuItem* item = [CCMenuItemLabel itemWithLabel:label block:^(id sender)
			{
				CCScene* scene = [ScreenshotRenderTextureScene node];
				[ReturnToMainMenuNode returnNodeWithParent:scene];
				[[CCDirector sharedDirector] replaceScene:scene];
			}];
			[menu addChild:item];
		}
		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"Fullscreen Motion-Blur with CCRT" fontName:fontName fontSize:fontSize];
			CCMenuItem* item = [CCMenuItemLabel itemWithLabel:label block:^(id sender)
			{
				CCScene* scene = [MotionBlurRenderTextureScene node];
				[ReturnToMainMenuNode returnNodeWithParent:scene];
				[[CCDirector sharedDirector] replaceScene:scene];
			}];
			[menu addChild:item];
		}
		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"Sketching with CCRenderTexture" fontName:fontName fontSize:fontSize];
			CCMenuItem* item = [CCMenuItemLabel itemWithLabel:label block:^(id sender)
			{
				CCScene* scene = [SketchRenderTextureScene node];
				[ReturnToMainMenuNode returnNodeWithParent:scene];
				[[CCDirector sharedDirector] replaceScene:scene];
			}];
			[menu addChild:item];
		}
		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"SetPixel with CCMutableTexture2D" fontName:fontName fontSize:fontSize];
			CCMenuItem* item = [CCMenuItemLabel itemWithLabel:label block:^(id sender)
			{
				CCScene* scene = [SetPixelScene node];
				[ReturnToMainMenuNode returnNodeWithParent:scene];
				[[CCDirector sharedDirector] replaceScene:scene];
			}];
			[menu addChild:item];
		}
		
		[menu alignItemsVertically];
	}
	
	return self;
}

-(void) onEnter
{
	[super onEnter];
	//[[CCDirector sharedDirector] replaceScene:[NodeRenderTextureScene node]];
}

-(void) loadBackground
{
	// load the screenshot image as background if available
	NSString* screenshotPath = [CCScreenshot screenshotPathForFile:@"screenshot.png"];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:screenshotPath]) 
	{
		// the screenshot texture must be removed from the texture cache, because we don't want to re-use
		// the previous screenshot that is already in memory, we want to force reloading the new one from disk
		[[CCTextureCache sharedTextureCache] removeTextureForKey:screenshotPath];

		CGSize winSize = [CCDirector sharedDirector].winSize;
		CCSprite* screenshotSprite = [CCSprite spriteWithFile:screenshotPath];
		screenshotSprite.position = CGPointMake(winSize.width / 2, winSize.height / 2);
		screenshotSprite.opacity = 100;
		[self addChild:screenshotSprite];
		[screenshotSprite.texture setAliasTexParameters];
	}
}

@end
