//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "PixelPerfectTouchScene.h"
#import "CCNodeExtensions.h"

@implementation PixelPerfectTouchScene

+(id) node
{
	CCNode* node = [super node];
	[node addChild:[PixelPerfectTouchLayer node]];
	return node;
}

@end

@implementation PixelPerfectTouchLayer

-(id) init
{
	if ((self = [super init])) 
	{
		director = [CCDirector sharedDirector];
		
		glClearColor(0.1f, 0.2f, 0.2f, 1.0f);
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		CGPoint center = CGPointMake(size.width / 2, size.height / 2);

		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"Touch To Detect Collisions" fontName:@"Arial" fontSize:20];
			label.position = CGPointMake(center.x, 300);
			[self addChild:label];
		}
		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"GREEN = touch inside bounding box, RED = touch on pixel" fontName:@"Arial" fontSize:12];
			label.position = CGPointMake(center.x, 280);
			[self addChild:label];
		}

		spriteA = [KKPixelMaskSprite spriteWithFile:@"imageA.png"];
		spriteA.position = CGPointMake(center.x - 120, 140);
		//spriteA.rotation = 22;
		spriteA.scale = 1.56789f;
		[self addChild:spriteA];
		
		spriteB = [KKPixelMaskSprite spriteWithFile:@"imageB.png" alphaThreshold:100];
		spriteB.position = CGPointMake(center.x + 120, 140);
		spriteB.rotation = 321;
		spriteB.scale = 1.333f;
		[self addChild:spriteB];
		
		// CCSprite was changed to add the drawTextureBox BOOL because the CC_SPRITE_DEBUG_DRAW macro is too inflexible
		spriteA.drawTextureBox = YES;
		spriteB.drawTextureBox = YES;
		
		self.isTouchEnabled = YES;
	}
	return self;
}

-(void) testTouchOnSprite:(UITouch*)touch
{
	// simple test if touch location is within sprite bounding box
	spriteA.color = ([spriteA containsTouch:touch]) ? ccGREEN : ccWHITE;
	spriteB.color = ([spriteB containsTouch:touch]) ? ccGREEN : ccWHITE;
	
	// test if touch point is on the pixel mask
	CGPoint location = [director convertToGL:[touch locationInView:director.openGLView]];
	spriteA.color = ([spriteA pixelMaskContainsPoint:location]) ? ccRED : spriteA.color;
	spriteB.color = ([spriteB pixelMaskContainsPoint:location]) ? ccRED : spriteB.color;
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self testTouchOnSprite:[touches anyObject]];
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self testTouchOnSprite:[touches anyObject]];
}

@end
