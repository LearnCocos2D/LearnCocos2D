//
//  HelloWorldLayer.m
//  Scrolling
//
//  Created by Steffen Itterheim on 12.12.12.
//  Copyright Steffen Itterheim 2012. All rights reserved.
//


#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "FakeScrollingLayer.h"
#import "CameraScrollingLayer.h"
#import "FollowScrollingLayer.h"
#import "ManualScrollingLayer.h"

#pragma mark - HelloWorldLayer

@implementation HelloWorldLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		ccColor4B color1 = ccc4(CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255, 255);
		ccColor4B color2 = ccc4(CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255, 255);
		CGPoint gradientVector = CGPointMake(CCRANDOM_MINUS1_1(), CCRANDOM_MINUS1_1());
		CCLayerGradient* gradient = [CCLayerGradient layerWithColor:color1 fadingTo:color2 alongVector:gradientVector];
		[self addChild:gradient];
		
		
		[CCMenuItemFont setFontSize:40];
		
		// For endless scrollers. Ideal for scrolling along one axis and little or no scrolling along the other axis. No touch conversion necessary.
		CCMenuItem *itemFakeScroll = [CCMenuItemFont itemWithString:@"Fake Scrolling" block:^(id sender) {
			[[CCDirector sharedDirector] replaceScene:[FakeScrollingLayer scene]];
		}];
		
		// For full flexibility and unidirectional scrolling. OpenGL knowledge helpful. Not fully compatible with CCMenu and other nodes.
		CCMenuItem *itemCameraScroll = [CCMenuItemFont itemWithString:@"CCCamera Scrolling" block:^(id sender) {
			[[CCDirector sharedDirector] replaceScene:[CameraScrollingLayer scene]];
		}];
		
		// Simplest way to implement unidirectional scrolling. No flexibility though. Always centers on followed node.
		CCMenuItem *itemFollowScroll = [CCMenuItemFont itemWithString:@"CCFollow Scrolling" block:^(id sender) {
			[[CCDirector sharedDirector] replaceScene:[FollowScrollingLayer scene]];
		}];
		
		// Full flexibility but implementation is entirely up to you. May be counterintuitive to scroll layer in opposite direction.
		CCMenuItem *itemManualScroll = [CCMenuItemFont itemWithString:@"Manual Scrolling" block:^(id sender) {
			[[CCDirector sharedDirector] replaceScene:[ManualScrollingLayer scene]];
		}];
		
		CCMenu *menu = [CCMenu menuWithItems:itemFakeScroll, itemCameraScroll, itemFollowScroll, itemManualScroll, nil];
		[menu alignItemsVerticallyWithPadding:22];
		[self addChild:menu];

		
#if TARGET_IPHONE_SIMULATOR
		CCLabelTTF* warn = [CCLabelTTF labelWithString:@"These demos require accelerometer input. Run them on a device!" fontName:@"Arial" fontSize:14];
		warn.position = CGPointMake(240, 300);
		warn.color = ccMAGENTA;
		[self addChild:warn];
#endif
	}
	return self;
}

@end
