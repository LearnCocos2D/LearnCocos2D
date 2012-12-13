//
//  BackButton.m
//  Cocos2D-Scrolling
//
//  Copyright Steffen Itterheim 2012. Distributed under MIT License.
//

#import "BackButton.h"
#import "HelloWorldLayer.h"

@implementation BackButton

-(id) init
{
	if ((self = [super init]))
	{
		[CCMenuItemFont setFontSize:38];
		
		CCMenuItem* itemBack = [CCMenuItemFont itemWithString:@"<< Back" block:^(id sender) {
			[[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
		}];
		
		CCMenu* menu = [CCMenu menuWithItems:itemBack, nil];
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		menu.position = CGPointMake(itemBack.contentSize.width * 0.5f + 2, (screenSize.height - 2) - itemBack.contentSize.height * 0.5f);
		[self addChild:menu];
	}
	return self;
}

@end
