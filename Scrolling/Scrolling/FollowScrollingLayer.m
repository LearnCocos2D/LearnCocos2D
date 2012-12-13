//
//  FollowScrollingLayer.m
//  Cocos2D-Scrolling
//
//  Copyright Steffen Itterheim 2012. Distributed under MIT License.
//

#import "FollowScrollingLayer.h"
#import "BackButton.h"

static const int kNumEnemies = 200;
static const int kWorldTileWidth = 4;
static const int kWorldTileHeight = 6;

@implementation FollowScrollingLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	FollowScrollingLayer *layer = [FollowScrollingLayer node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		_screenSize = [CCDirector sharedDirector].winSize;
		
		CCSpriteBatchNode* bgBatch = [CCSpriteBatchNode batchNodeWithFile:@"stars.png"];
		[self addChild:bgBatch];
		
		for (int i = 0; i < kWorldTileWidth; i++)
		{
			for (int j = 0; j < kWorldTileHeight; j++)
			{
				CCSprite* bg = [CCSprite spriteWithFile:@"stars.png"];
				bg.position = CGPointMake(bg.contentSize.width * i, bg.contentSize.height * j);
				bg.anchorPoint = CGPointMake(0, 0); // align with lower left corner
				[bgBatch addChild:bg];
			}
		}
		
		_worldSize = CGSizeMake(bgBatch.texture.contentSize.width * kWorldTileWidth,
								bgBatch.texture.contentSize.height * kWorldTileHeight);
		NSLog(@"world size: %.0fx%.0f", _worldSize.width, _worldSize.height);
		
		// In contrast to CCCamera scrolling the back button can be activated when you tap it at its current location.
		// Since the button is a child of the layer, it will still leave the screen however. Normally you'd add such
		// buttons on a separate, non-scrolling user interface (or HUD) layer.
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
		
		// lets random enemies fly through the world
		_enemyBatch = [CCSpriteBatchNode batchNodeWithFile:@"Icon.png"];
		[self addChild:_enemyBatch];
		
		for (int i = 0; i < kNumEnemies; i++)
		{
			CCSprite* enemy = [CCSprite spriteWithFile:@"Icon.png"];
			enemy.color = ccRED;
			enemy.scale = 0.5f;
			enemy.tag = i;
			[_enemyBatch addChild:enemy];
			[self moveEnemy:enemy];
			
			// only randomize initial position
			enemy.position = CGPointMake(CCRANDOM_0_1() * _worldSize.width, CCRANDOM_0_1() * _worldSize.height);
		}
		
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:[CCDirector sharedDirector].animationInterval];
		self.isAccelerometerEnabled = YES;
		
		[self scheduleUpdate];

	
		// Let the layer follow the player sprite, while restricting the scrolling to within the world size.
		// This is really all you need to do. But it's really all you *can* do either without modifying CCFollow's code.
		CGRect worldBoundary = CGRectMake(0, 0, _worldSize.width, _worldSize.height);
		[self runAction:[CCFollow actionWithTarget:_player worldBoundary:worldBoundary]];
	}
	return self;
}

-(void) moveEnemy:(CCNode*)enemy
{
	id delay = [CCDelayTime actionWithDuration:CCRANDOM_0_1() * 7.0f + 3.0f];
	id move = [CCMoveTo actionWithDuration:30.0f position:CGPointMake(CCRANDOM_0_1() * _worldSize.width,
																	  CCRANDOM_0_1() * _worldSize.height)];
	id easeMove = [CCEaseBackInOut actionWithAction:move];
	id startOver = [CCCallBlock actionWithBlock:^{
		[self moveEnemy:enemy];
	}];
	id sequence = [CCSequence actions:delay, easeMove, startOver, nil];
	[enemy runAction:sequence];
}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	CGPoint playerPos = _player.position;
	playerPos.x += acceleration.y * 20.0f;
	playerPos.y += -acceleration.x * 20.0f;
	
	playerPos.x = clampf(playerPos.x, 0, _worldSize.width);
	playerPos.y = clampf(playerPos.y, 0, _worldSize.height);
	
	_player.position = playerPos;
}

-(void) update:(ccTime)delta
{
	// Notice: background images do not need to change their positions anymore, and no camera code here either.
	
	// simple collision test
	_player.color = ccWHITE;
	_player.flipY = NO;
	for (int i = 0; i < kNumEnemies; i++)
	{
		CCNode* enemy = [_enemyBatch getChildByTag:i];
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
