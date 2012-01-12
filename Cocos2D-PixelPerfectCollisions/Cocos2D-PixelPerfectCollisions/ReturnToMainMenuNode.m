//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "ReturnToMainMenuNode.h"
#import "MainMenuScene.h"
#import "KKScreenshot.h"

@implementation ReturnToMainMenuNode

-(id) initWithParent:(CCNode*)parentNode
{
	if ((self = [super init]))
	{
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"<= BACK" fontName:@"Arial" fontSize:24];
		label.color = ccMAGENTA;

		id tint1 = [CCTintTo actionWithDuration:0.333f red:255 green:0 blue:0];
		id tint2 = [CCTintTo actionWithDuration:0.333f red:255 green:255 blue:0];
		id tint3 = [CCTintTo actionWithDuration:0.333f red:0 green:255 blue:0];
		id seq = [CCSequence actions:tint1, tint2, tint3, nil];
		id repeat = [CCRepeatForever actionWithAction:seq];
		[label runAction:repeat];

		// label background
		CCLayerColor* bg = [CCLayerColor layerWithColor:ccc4(50, 50, 50, 200) 
												  width:label.contentSize.width
												 height:label.contentSize.height];
		[label addChild:bg z:-1];

		CCMenuItem* item = [CCMenuItemLabel itemWithLabel:label block:^(id sender)
		{
			// store the parent for screenshot, it will be nil after removeFromParentAndCleanup
			CCNode* parentNode = [self parent];
			[self removeFromParentAndCleanup:YES];
			
			[KKScreenshot screenshotWithStartNode:parentNode filename:@"screenshot.png"];
			[[CCDirector sharedDirector] replaceScene:[MainMenuScene node]];
		}];
		
		CCMenu* menu = [CCMenu menuWithItems:item, nil];
		[menu alignItemsVertically];
		[self addChild:menu];
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		menu.position = CGPointMake(menu.position.x - winSize.width / 2 + label.contentSize.width / 2, 
									menu.position.y + winSize.height / 2 - label.contentSize.height / 2);
		
		[parentNode addChild:self z:100];
	}
	return self;
}

+(id) returnNodeWithParent:(CCNode*)parentNode
{
	return [[[self alloc] initWithParent:parentNode] autorelease];
}

@end
