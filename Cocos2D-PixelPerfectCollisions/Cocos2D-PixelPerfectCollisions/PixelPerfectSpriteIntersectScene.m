//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "PixelPerfectSpriteIntersectScene.h"
#import "CCNodeExtensions.h"

@implementation PixelPerfectSpriteIntersectScene
+(id) node
{
	CCNode* node = [super node];
	[node addChild:[PixelPerfectSpriteIntersectLayer node]];
	return node;
}
@end


@implementation PixelPerfectSpriteIntersectLayer

-(id) init
{
	if ((self = [super init])) 
	{
		director = [CCDirector sharedDirector];
		
		glClearColor(0.1f, 0.2f, 0.2f, 1.0f);
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		CGPoint center = CGPointMake(size.width / 2, size.height / 2);
		
		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"Touch To Move Sprite" fontName:@"Arial" fontSize:20];
			label.position = CGPointMake(center.x, 300);
			[self addChild:label];
		}
		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"GREEN = bounding boxes intersect, RED = pixel mask overlap" fontName:@"Arial" fontSize:12];
			label.position = CGPointMake(center.x, 280);
			[self addChild:label];
		}
		
		spriteA = [KKPixelMaskSprite spriteWithFile:@"imageA.png" alphaThreshold:0];
		spriteA.position = center;
		//spriteA.rotation = 22;
		//spriteA.scale = 1.76789f;
		[self addChild:spriteA];
		
		spriteB = [KKPixelMaskSprite spriteWithFile:@"Icon.png" alphaThreshold:0];
		spriteB.position = CGPointMake(center.x - 180 /*+ 112*/, center.y - 10);
		//spriteB.rotation = 321;
		//spriteB.scale = 1.333f;
		[self addChild:spriteB];
		
		// CCSprite was changed to add the drawTextureBox BOOL because the CC_SPRITE_DEBUG_DRAW macro is too inflexible
		spriteA.drawTextureBox = YES;
		spriteB.drawTextureBox = YES;
		
		self.isTouchEnabled = YES;
	
		[self scheduleUpdate];
	}
	return self;
}

-(void) moveSpriteWithTouch:(UITouch*)touch
{
	CGPoint location = [director convertToGL:[touch locationInView:director.openGLView]];
	spriteB.position = CGPointMake(location.x, location.y + 40);

	ccColor3B color = [spriteA intersectsNode:spriteB] ? ccGREEN : ccWHITE;
	spriteA.color = [spriteA pixelMaskIntersectsNode:spriteB] ? ccRED : color;
	
	// both tests will return the same result
	color = [spriteA intersectsNode:spriteB] ? ccYELLOW : ccWHITE;
	spriteB.color = [spriteB pixelMaskIntersectsNode:spriteA] ? ccMAGENTA : color;
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self moveSpriteWithTouch:[touches anyObject]];
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self moveSpriteWithTouch:[touches anyObject]];
}



#pragma mark Benchmarking

#import <mach/mach_time.h>

struct Result
{
    int iterations;
    double totalDuration;
    double singleIterationNanosec;
};

-(void) update:(ccTime)delta
{
	[self unscheduleUpdate];
	
	/*
	struct mach_timebase_info tbinfo;
    mach_timebase_info( &tbinfo );
    
	uint64_t	mStartTime = mach_absolute_time();
	uint64_t	mEndTime = 0;
    int			mIterations = 100000;


	for (int i = 0; i < mIterations; i++)
	{
		[spriteA pixelMaskIntersectsWithNode:spriteB];
	}
	
	
	mEndTime = mach_absolute_time();
    uint64_t duration = mEndTime - mStartTime;
    double floatDuration = duration * tbinfo.numer / tbinfo.denom;
    
    struct Result result = {
        mIterations,
        floatDuration / 1000000000.0,
        floatDuration / mIterations
    };
	result.iterations = mIterations;
	
	CCLOG(@"Duration: %.1f seconds, each: %.1f ns", result.totalDuration, result.singleIterationNanosec);
	 */
}

@end