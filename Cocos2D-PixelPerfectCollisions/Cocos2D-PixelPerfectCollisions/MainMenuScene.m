//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "MainMenuScene.h"
#import "ReturnToMainMenuNode.h"
#import "KKScreenshot.h"

#import "PixelPerfectTouchScene.h"
#import "PixelPerfectSpriteIntersectScene.h"

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
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"Touch Collision Detection" fontName:fontName fontSize:fontSize];
			CCMenuItem* item = [CCMenuItemLabel itemWithLabel:label block:^(id sender)
			{
				CCScene* scene = [PixelPerfectTouchScene node];
				[ReturnToMainMenuNode returnNodeWithParent:scene];
				[[CCDirector sharedDirector] replaceScene:scene];
			}];
			[menu addChild:item];
		}
		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"Pixel-Perfect Sprite Intersection" fontName:fontName fontSize:fontSize];
			CCMenuItem* item = [CCMenuItemLabel itemWithLabel:label block:^(id sender)
			{
				CCScene* scene = [PixelPerfectSpriteIntersectScene node];
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
	NSString* screenshotPath = [KKScreenshot screenshotPathForFile:@"screenshot.png"];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:screenshotPath]) 
	{
		// the screenshot texture must be removed from the texture cache, because we don't want to re-use
		// the previous screenshot that is already in memory, we want to force reloading the new one from disk
		[[CCTextureCache sharedTextureCache] removeTextureForKey:screenshotPath];

		CGSize winSize = [CCDirector sharedDirector].winSize;
		CCSprite* screenshotSprite = [CCSprite spriteWithFile:screenshotPath];
		screenshotSprite.position = CGPointMake(winSize.width / 2, winSize.height / 2);
		screenshotSprite.opacity = 220;
		[self addChild:screenshotSprite];
		[screenshotSprite.texture setAliasTexParameters];
	}
}

@end
