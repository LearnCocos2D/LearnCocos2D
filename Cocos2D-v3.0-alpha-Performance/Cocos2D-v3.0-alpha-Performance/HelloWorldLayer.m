//
//  HelloWorldLayer.m
//  Cocos2D-v2.1-Performance
//
//  Created by Steffen Itterheim on 12/12/13.
//  Copyright Steffen Itterheim 2013. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "cocos2d-ui.h"

#define USE_BATCH_NODE 1
#define BENCHMARK_IMAGE_NAME @"benchmark_object.png"
const double TARGET_FRAMERATE = 30.0;

@implementation HelloWorldLayer
{
    CCButton *_startButton;
    CCLabelTTF *_resultText;
    CCTexture *_texture;
    
#if USE_BATCH_NODE
    CCSpriteBatchNode *_container;
#else
	CCNode *_container;
#endif
    int _frameCount;
    double _elapsed;
	double _lastUpdateTime;
    BOOL _started;
    int _failCount;
    int _waitFrames;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
		[CCDirector sharedDirector].displayStats = NO;
		[CCDirector sharedDirector].animationInterval = 1.0 / 60.0;
		//[[CCFileUtils sharedFileUtils] setiPadSuffix:@"-hd"];
		[[CCFileUtils sharedFileUtils] setiPadRetinaDisplaySuffix:@"-hd"];
		
		CCSprite* background = [CCSprite spriteWithImageNamed:@"background.jpg"];
		background.anchorPoint = CGPointZero;
		background.position = CGPointMake([CCDirector sharedDirector].viewSize.width, 0);
		background.rotation = 270;
		[self addChild:background];
		
		_texture = [CCTexture textureWithFile:BENCHMARK_IMAGE_NAME];
		NSLog(@"benchmark texture dimension in pixels: {%.0f, %.0f}", _texture.contentSizeInPixels.width, _texture.contentSizeInPixels.height);
        
        // the container will hold all test objects
#if USE_BATCH_NODE
        _container = [CCSpriteBatchNode batchNodeWithTexture:_texture];
#else
		_container = [CCNode node];
#endif
        [self addChild:_container];
		

		_startButton = [CCButton buttonWithTitle:@"Start benchmark" fontName:@"Chalkduster" fontSize:30];
		[_startButton setTarget:self selector:@selector(onStartButtonPressed)];
		[self addChild:_startButton];
		_startButton.position = CGPointMake(350, 150);
      
        _started = NO;
		
		//[self schedule:@selector(update:) interval:0.0166666];
    }
    return self;
}

// there is currently no way to schedule an "every frame" selector (interval = 0 freezes the app)
-(void) visit
{
	[super visit];
	
    if (!_started) return;

	// passed-in delta seems to be the scheduled interval rather than actual delta time
	//NSLog(@"delta: %f  cur: %f  last: %f  diff: %f", delta, _scheduler.currentTime, _scheduler.lastUpdateTime, _scheduler.currentTime - _scheduler.lastUpdateTime);
	double delta = _scheduler.currentTime - _lastUpdateTime;
    
    _elapsed += delta;
	_lastUpdateTime = _scheduler.currentTime;
    ++_frameCount;
    
    if (_frameCount % _waitFrames == 0)
    {
        double targetFPS = TARGET_FRAMERATE;
        double realFPS = _waitFrames / _elapsed;
        
        if (ceil(realFPS) >= targetFPS)
        {
			//NSLog(@"FPS: %.0f (delta %f) with %u sprites, fail count: %u", ceilf(realFPS), delta, _container.children.count, _failCount);
            int numObjects = _failCount ? 5 : 25;
            [self addTestObjects:numObjects];
            _failCount = 0;
        }
        else
        {
            ++_failCount;
            
            if (_failCount > 15)
                _waitFrames = 5; // slow down creation process to be more exact
            if (_failCount > 20)
                _waitFrames = 10;
            if (_failCount == 25)
                [self benchmarkComplete]; // target fps not reached for a while
        }
		
        _elapsed = _frameCount = 0;
    }
    
	for (CCNode* child in _container.children)
	{
		child.rotation += 0.5f;
	}
}

-(void) onStartButtonPressed
{
    NSLog(@"starting benchmark");
    
    _startButton.visible = NO;
    _started = YES;
    _failCount = 0;
    _waitFrames = 3;
    
    [_resultText removeFromParent];
    _resultText = nil;
    
    _frameCount = 0;
	
#if TARGET_IPHONE_SIMULATOR
    [self addTestObjects:10];
#else
    [self addTestObjects:500];
#endif
}

-(void) benchmarkComplete
{
    _started = NO;
    _startButton.visible = YES;
    
    int frameRate = (int)TARGET_FRAMERATE;
    
    NSLog(@"benchmark complete!");
    NSLog(@"fps: %d", frameRate);
    NSLog(@"number of objects: %d", _container.children.count);
    
    NSString *resultString = [NSString stringWithFormat:@"Result:\n%d objects\nwith %d fps",
                              _container.children.count, frameRate];
    
	_resultText = [CCLabelTTF labelWithString:resultString
									 fontName:@"Arial"
									 fontSize:24
								   dimensions:CGSizeMake(250, 200)];
	_resultText.anchorPoint = CGPointZero;
    _resultText.color = ccGREEN;
	CGPoint pos = CGPointMake((320 - _resultText.contentSize.width / 2) / 2,
							  (480 - _resultText.contentSize.height / 2) / 4);
	_resultText.position = pos;
    
    [self addChild:_resultText];
    [_container removeAllChildren];
}

- (void)addTestObjects:(int)numObjects
{
    int border = 15 * 2;
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		border *= 2 / CC_CONTENT_SCALE_FACTOR();
	}

	CGSize s = [CCDirector sharedDirector].viewSize;
    
    for (int i=0; i<numObjects; ++i)
    {
		CCSprite* egg = [CCSprite spriteWithTexture:_texture];
		CGFloat x = (CCRANDOM_0_1() * (s.width - border * 2)) + border;
		CGFloat y = (CCRANDOM_0_1() * (s.height - border * 2)) + border;
		egg.position = CGPointMake(x, y);
		egg.anchorPoint = CGPointZero;
        egg.rotation = CCRANDOM_0_1() * 360.0;
        [_container addChild:egg];
    }
}

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

@end
