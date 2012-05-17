//
//  HelloWorldLayer.m
//  Cocos2D-ZoomInOnMe
//
//  Created by Steffen Itterheim on 17.05.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "HelloWorldLayer.h"
#import "AppDelegate.h"

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
	self = [super init];
	if (self)
	{
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CGPoint screenCenter = CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);

		CCLayerGradient* gradient = [CCLayerGradient layerWithColor:ccc4(255, 255, 0, 255) fadingTo:ccc4(0, 255, 255, 255)];
		[self addChild:gradient z:-2];
		
		CCSprite* bg = [CCSprite spriteWithFile:@"Default.png"];
		bg.rotation = 270;
		bg.position = screenCenter;
		bg.color = ccGRAY;
		bg.scale = CC_CONTENT_SCALE_FACTOR();
		//bg.opacity = 100;
		[self addChild:bg z:-2];
		
		player = [CCSprite spriteWithFile:@"Icon.png"];
		player.flipY = YES;
		player.color = ccMAGENTA;
		player.position = screenCenter;
		[self addChild:player z:-1];
		
		[self scheduleUpdate];
		[self scheduleOnce:@selector(zoomInOnPlayer:) delay:2.0f];
	}
	return self;
}

const float kZoomInFactor = 6.0f;

-(void) update:(ccTime)delta
{
	// move player
	if (player.numberOfRunningActions == 0)
	{
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CGPoint randomPos = CGPointMake(CCRANDOM_0_1() * screenSize.width, CCRANDOM_0_1() * screenSize.height);
		id move = [CCMoveTo actionWithDuration:1.2f position:randomPos];
		id ease = [CCEaseBackInOut actionWithAction:move];
		[player runAction:ease];
	}
	
	if (isZooming)
	{
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CGPoint screenCenter = CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
		
		CGPoint offsetToCenter = ccpSub(screenCenter, player.position);
		self.position = ccpMult(offsetToCenter, self.scale);
		self.position = ccpSub(self.position, ccpMult(offsetToCenter, (kZoomInFactor - self.scale) / (kZoomInFactor - 1.0f)));

		//CCLOG(@"pos: %.1f, %.1f, offset: %.1f, %.1f, scale: %.2f", self.position.x, self.position.y, offsetToCenter.x, offsetToCenter.y, self.scale);
	}
}

-(void) zoomInOnPlayer:(ccTime)delta
{
	// just to be sure no other actions interfere
	[self stopAllActions];
	
	isZooming = YES;
	id zoomIn = [CCScaleTo actionWithDuration:3.0f scale:kZoomInFactor];
	id zoomOut = [CCScaleTo actionWithDuration:2.0f scale:1.0f];
	id reset = [CCCallBlock actionWithBlock:^{
		CCLOG(@"zoom in/out complete");
		isZooming = NO;
		self.position = CGPointZero;
		[self scheduleOnce:@selector(zoomInOnPlayer:) delay:CCRANDOM_0_1() * 2.0f + 2.0f];
	}];
	id sequence = [CCSequence actions:zoomIn, zoomOut, reset, nil];
	[self runAction:sequence];
}

-(void) draw
{
	// player center
	ccDrawColor4F(0, 1, 0, 1);
	CGPoint origin = CGPointMake(player.position.x - player.contentSize.width * player.anchorPoint.x,
								 player.position.y - player.contentSize.height * player.anchorPoint.y);
	CGPoint destination = CGPointMake(player.position.x + player.contentSize.width * player.anchorPoint.x,
									  player.position.y + player.contentSize.height * player.anchorPoint.y);
	ccDrawLine(origin, destination);

	origin = CGPointMake(player.position.x - player.contentSize.width * player.anchorPoint.x,
						 player.position.y + player.contentSize.height * player.anchorPoint.y);
	destination = CGPointMake(player.position.x + player.contentSize.width * player.anchorPoint.x,
							  player.position.y - player.contentSize.height * player.anchorPoint.y);
	ccDrawLine(origin, destination);
}

@end
