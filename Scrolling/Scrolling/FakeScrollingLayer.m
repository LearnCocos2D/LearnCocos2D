//
//  FakeScrollingScene.m
//  Cocos2D-Scrolling
//
//  Created by Steffen Itterheim on 12.12.12.
//  Copyright 2012 Steffen Itterheim. All rights reserved.
//

#import "FakeScrollingLayer.h"
#import "BackButton.h"

static const int kNumEnemies = 20;
static const int kScrollSpeed = 3;

@implementation FakeScrollingLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	FakeScrollingLayer *layer = [FakeScrollingLayer node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		_screenSize = [CCDirector sharedDirector].winSize;
		
		_bg1 = [CCSprite spriteWithFile:@"stars.png"];
		_bg1.position = CGPointMake(0, _screenSize.height * 0.5f);
		_bg1.anchorPoint = CGPointMake(0, 0.5f);
		[self addChild:_bg1];
		
		_bg2 = [CCSprite spriteWithFile:@"stars.png"];
		_bg2.position = CGPointMake(_bg2.contentSize.width, _bg1.position.y);
		_bg2.anchorPoint = CGPointMake(0, 0.5f);
		[self addChild:_bg2];

		[self addChild:[BackButton node]];
		
		_player = [CCSprite spriteWithFile:@"Icon.png"];
		_player.position = CGPointMake(_screenSize.width / 2, _screenSize.height / 2);
		[self addChild:_player];
		
		CCLabelAtlas* posLabel = [CCLabelAtlas labelWithString:@"0/0" charMapFile:@"fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'];
		posLabel.position = CGPointMake(28, 28);
		posLabel.anchorPoint = CGPointMake(0.5f, 0.5f);
		posLabel.color = ccGREEN;
		posLabel.tag = 1;
		[_player addChild:posLabel];
		
		// lets random enemies fly through the screen
		for (int i = 0; i < kNumEnemies; i++)
		{
			CCSprite* enemy = [CCSprite spriteWithFile:@"Icon.png"];
			enemy.color = ccRED;
			enemy.scale = 0.5f;
			enemy.tag = i;
			[self addChild:enemy];
			[self moveEnemy:enemy];
		}
		
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:[CCDirector sharedDirector].animationInterval];
		self.isAccelerometerEnabled = YES;
		
		[self scheduleUpdate];
	}
	return self;
}

-(void) moveEnemy:(CCNode*)enemy
{
	enemy.position = CGPointMake(CCRANDOM_0_1() * _screenSize.width + _screenSize.width + enemy.contentSize.width,
								 CCRANDOM_0_1() * _screenSize.height);
	
	id delay = [CCDelayTime actionWithDuration:CCRANDOM_0_1() * 6.0f + 0.5f];
	id move = [CCMoveTo actionWithDuration:4.0f position:CGPointMake(CCRANDOM_0_1() * -_screenSize.width - enemy.contentSize.width,
																	 CCRANDOM_0_1() * _screenSize.height)];
	id startOver = [CCCallBlock actionWithBlock:^{
		[self moveEnemy:enemy];
	}];
	id sequence = [CCSequence actions:delay, move, startOver, nil];
	[enemy runAction:sequence];
}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	CGPoint playerPos = _player.position;
	playerPos.x += acceleration.y * 10.0f;
	playerPos.y += -acceleration.x * 10.0f;
	
	playerPos.x = clampf(playerPos.x, 0, _screenSize.width);
	playerPos.y = clampf(playerPos.y, 0, _screenSize.height);
	
	_player.position = playerPos;
}

-(void) update:(ccTime)delta
{
	CGPoint bg1Pos = _bg1.position;
	CGPoint bg2Pos = _bg2.position;
	bg1Pos.x -= kScrollSpeed;
	bg2Pos.x -= kScrollSpeed;
	
	// move scrolling background back from left to right end to achieve "endless" scrolling
	if (bg1Pos.x < -(_bg1.contentSize.width))
	{
		bg1Pos.x += _bg1.contentSize.width;
		bg2Pos.x += _bg2.contentSize.width;
	}
	
	// remove any inaccuracies by assigning only int values (this prevents floating point rounding errors accumulating over time)
	bg1Pos.x = (int)bg1Pos.x;
	bg2Pos.x = (int)bg2Pos.x;
	_bg1.position = bg1Pos;
	_bg2.position = bg2Pos;
	
	// simple collision test
	_player.color = ccWHITE;
	_player.flipY = NO;
	for (int i = 0; i < kNumEnemies; i++)
	{
		CCNode* enemy = [self getChildByTag:i];
		if (CGRectIntersectsRect([enemy boundingBox], [_player boundingBox]))
		{
			_player.color = ccc3(CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255);
			_player.flipY = YES;
			break;
		}
	}
	
	CCLabelAtlas* posLabel = (CCLabelAtlas*)[_player getChildByTag:1];
	posLabel.string = [NSString stringWithFormat:@"%.0f/%.0f", _player.position.x, _player.position.y];
}

@end
