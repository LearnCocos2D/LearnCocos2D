//
//  HelloWorldLayer.m
//  Cocos2D-CoordinateSpaces
//
//  Created by Steffen Itterheim on 06.09.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import <objc/runtime.h>

@implementation CustomDrawSprite


-(void) setPositionRelativeToParentPosition:(CGPoint)pos
{
    CGPoint parentAP = parent_.anchorPoint;
    CGSize parentCS = parent_.contentSize;
    self.position = ccp((parentCS.width * parentAP.x) + pos.x,
                        (parentCS.height * parentAP.y) + pos.y);
}

-(void) draw
{
	//ccDrawLine(self.position, ccpAdd(self.position, ccp(100, 100)));

	glEnable( GL_BLEND );
    glBlendFunc( GL_SRC_COLOR, GL_DST_COLOR );
	
	[super draw];
		
	glDisable(GL_BLEND);

	CGSize s = self.contentSize;
	CGPoint vertices[4] = {
		ccp(0,0), ccp(s.width,0),
		ccp(s.width,s.height), ccp(0,s.height)
	};
	ccDrawPoly(vertices, 4, YES);

	ccDrawColor4F(1, 0, 1, 1);
	
	for (int i = 12; i < 30; i+=1)
	{
		ccDrawCircle(ccpMult(self.anchorPointInPoints, CC_CONTENT_SCALE_FACTOR()), i, 0, 12, NO);
	}
	
	ccDrawColor4F(1, 1, 1, 1);
}

@end

@implementation CustomLabelTTF
-(void) draw
{
	glEnable( GL_BLEND );
    glBlendFunc( GL_SRC_COLOR, GL_DST_COLOR );
	
	[super draw];
	
	glDisable(GL_BLEND);
}

-(void) setPositionRelativeToParentPosition:(CGPoint)pos
{
    CGPoint parentAP = parent_.anchorPoint;
    CGSize parentCS = parent_.contentSize;
    self.position = ccp((parentCS.width * parentAP.x) + pos.x,
                        (parentCS.height * parentAP.y) + pos.y);
}
@end

#pragma mark - HelloWorldLayer

@implementation HelloWorldLayer
static HelloWorldLayer* instance;

-(void) dealloc
{
    // you could also nil the instance in cleanup to let it go earlier
    instance = nil;
}

+(HelloWorldLayer*) sharedMyScene
{
    NSAssert1(instance, @"%@ temporary singleton is not yet initialized!", NSStringFromClass([self class]));
    return instance;
}


+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

-(void) playerDied:(NSNotification*)notification
{
    CCLOG(@"player died: %@ - received object: %@ - user info: %@",
          notification, notification.object, notification.userInfo);
}

-(id) init
{
	if ((self = [super init]))
	{
		NSAssert1(instance == nil, @"there's already an active instance of %@", NSStringFromClass([self class]));
        instance = self;

		// register for player died notification
		NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
		[notifyCenter addObserver:self
						 selector:@selector(playerDied:)
							 name:kPlayerDiedNotification
						   object:nil];
		[notifyCenter postNotificationName:kPlayerDiedNotification object:self];
		
		
		size_t instanceSize = class_getInstanceSize([CCMenu class]);
		CCLOG(@"sprite size: %lu", instanceSize);
		
		glClearColor(0.3f, 0.2f, 0.2f, 0.5f);

		for (int i = 0; i < 5; i++)
		{
			CCSprite* sprite = [CustomDrawSprite spriteWithFile:@"Default-Landscape~ipad.png"];
			CCLabelTTF* label = [CustomLabelTTF labelWithString:@"anchorPoint 0.5x0.5" fontName:@"Arial" fontSize:80];
			label.color = ccRED;
			[sprite addChild:label];
			[label setPositionRelativeToParentPosition:ccp(0, 140)];

			switch (i) {
				case 1:
					sprite.anchorPoint = ccp(1.2, 1.2);
					sprite.opacity = 150;
					label.string = @"anchorPoint 1x1";
					//[label setPositionRelativeToParentPosition:ccp(-100, -50)];
					break;
				case 2:
					sprite.anchorPoint = ccp(1.2, -0.2);
					sprite.opacity = 150;
					label.string = @"anchorPoint 1x0";
					break;
				case 3:
					sprite.anchorPoint = ccp(-0.2, 1.2);
					sprite.opacity = 150;
					label.string = @"anchorPoint 0x1";
					break;
				case 4:
					sprite.anchorPoint = ccp(-0.2, -0.2);
					sprite.opacity = 150;
					label.string = @"anchorPoint 0x0";
					break;
			}
			
			sprite.scale = 0.2f;
			sprite.skewX = 25;
			sprite.position = ccp(240, 160);
			sprite.rotation = 10;
			[self addChild:sprite];

		}

		
		CCLabelTTF *label = [CustomLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position = ccp(size.width / 2, size.height / 2);
		//[self addChild: label];
		
		// create a deep hierarchy of sprites
		sprite1 = [CustomDrawSprite spriteWithFile:@"Icon.png"];
		//sprite1.color = ccGREEN;
		//sprite1.position = ccp(300, 200);
		[label addChild:sprite1 z:100 tag:1];
		[sprite1 setPositionRelativeToParentPosition:CGPointZero];
		
		sprite2 = [CCSprite spriteWithFile:@"Icon.png"];
		sprite2.color = ccBLUE;
		[self addChild:sprite2];
		
		
        id action = [CCMoveTo actionWithDuration:5 position:ccp(480,320)];
        [sprite2 runAction:action];
		
        CCParticleSystem *effect = [CCParticleSystemQuad particleWithFile:@"stars.plist"];
		effect.scale = 1;
		effect.duration = 100;
		//      effect.positionType = kCCPositionTypeFree;
		//      effect.positionType = kCCPositionTypeRelative;
		//      effect.positionType = kCCPositionTypeGrouped; changing of positionType to any of this options does not make any sense
		effect.position = ccp(240, 160);
        [self addChild:effect z:100];
		[effect resetSystem];
        [self runAction:[CCFollow actionWithTarget:sprite2]];
		
		
		/*
		CCSprite* sprite3 = [CustomDrawSprite spriteWithFile:@"Icon.png"];
		sprite3.color = ccMAGENTA;
		[sprite2 addChild:sprite3];

		CCSprite* sprite4 = [CustomDrawSprite spriteWithFile:@"Icon.png"];
		sprite4.color = ccYELLOW;
		[sprite3 addChild:sprite4];

		CCLOG(@"sprite Pos: %.1f, %.1f", sprite4.position.x, sprite4.position.y);
	
		
		sprite5 = [CustomDrawSprite spriteWithFile:@"Icon.png"];
		sprite5.color = ccRED;
		sprite5.position = ccp(-80, -30);
		[sprite4 addChild:sprite5 z:0 tag:5];

		
		self.vertexZ = -110;
		sprite1.vertexZ = -100;
		sprite2.vertexZ = 222;
		sprite3.vertexZ = -10;
		sprite4.vertexZ = 500;
		sprite5.vertexZ = 400;
		*/
		
		/*
		// use converted coordinates to display some other sprites
		CCDirector* director = [CCDirector sharedDirector];
		CGPoint screenCenter = ccp(director.winSize.width / 2, director.winSize.height / 2);
		CGPoint convPos = [sprite1 convertToWorldSpace:screenCenter];
		CGPoint convPosAR = [sprite1 convertToWorldSpaceAR:screenCenter];
		
		if (NO)
		{
			convPos = [sprite3 convertToWorldSpace:convPos];
			convPosAR = [sprite3 convertToWorldSpace:convPos];
			convPos = [sprite2 convertToWorldSpace:convPos];
			convPosAR = [sprite2 convertToWorldSpace:convPos];
			convPos = [sprite1 convertToWorldSpace:convPos];
			convPosAR = [sprite1 convertToWorldSpace:convPos];
		}
		
		CCLOG(@"screenCenter: %.1f, %.1f", screenCenter.x, screenCenter.y);
		CCLOG(@"convPos: %.1f, %.1f -- convPosAR: %.1f, %.1f", convPos.x, convPos.y, convPosAR.x, convPosAR.y);
		
		CCSprite* pos1 = [CCSprite spriteWithFile:@"Icon.png"];
		pos1.scale = 0.4f;
		pos1.position = convPos;
		pos1.color = ccYELLOW;
		[self addChild:pos1 z:1 tag:11];

		CCSprite* pos2 = [CCSprite spriteWithFile:@"Icon.png"];
		pos2.scale = 0.4f;
		pos2.position = convPosAR;
		pos2.color = ccGREEN;
		[self addChild:pos2 z:1 tag:12];
		
		
		//sprite1.position = CGPointZero;
		id move1 = [CCMoveTo actionWithDuration:9 position:ccp(480/5, 320/5)];
		id move2 = [CCMoveTo actionWithDuration:9 position:CGPointZero];
		id rot = [CCRotateBy actionWithDuration:100 angle:360];
		id seq = [CCSequence actions:move1, move2, nil];
		id rep = [CCRepeatForever actionWithAction:seq];
		[sprite5 runAction:rep];
		[sprite1 runAction:rot];
		//sprite1.position = ccp(130, 80);
		*/
		 
		[self scheduleUpdate];
		
		self.isTouchEnabled = YES;

		//self.visible = NO;
	}
	return self;
}

-(void) onEnter
{
	[super onEnter];
}

-(void) updateTouchLocationWithTouches:(NSSet*)touches
{
	UITouch* touch = [touches anyObject];
	touchLocation = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self updateTouchLocationWithTouches:touches];
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self updateTouchLocationWithTouches:touches];
}

-(void) update:(ccTime)delta
{
	/*
	//self.parent.rotation = 20;

	CCNode* sprite1 = [self getChildByTag:1];
	CCNode* pos1 = [self getChildByTag:11];
	CCNode* pos2 = [self getChildByTag:12];

	CCDirector* director = [CCDirector sharedDirector];
	CGPoint screenCenter = ccp(director.winSize.width / 2, director.winSize.height / 2);
	CGPoint convPos = [sprite1 convertToNodeSpace:touchLocation];
	CGPoint convPosAR = [sprite1 convertToNodeSpaceAR:touchLocation];
	pos1.position = convPos;
	pos2.position = convPosAR;

	CGPoint pos = sprite5.position;
	//CCLOG(@"convPos: %.1f, %.1f -- convPosAR: %.1f, %.1f -- pos: %.1f, %.1f", convPos.x, convPos.y, convPosAR.x, convPosAR.y, pos.x, pos.y);
	
	//CCLOG(@"d %f", delta);
	 */
}

-(void) visit
{
	/*
	ccPointSize(4);
	ccDrawColor4F(1.0f, 0.6f, 0.3f, 1.0f);

	{
		CGPoint points[4] = {ccp(50, 55), ccp(55, 35), ccp(45, 60), ccp(35, 65)};
		ccDrawPoints(points, 4);
	}
	{
		CGPoint points[4] = {ccp(150, 155), ccp(155, 135), ccp(115, 160), ccp(135, 165)};
		ccDrawPoly(points, 4, YES);
	}
	
	ccDrawPoint(ccp(240, 160));
	ccDrawLine(ccp(100, 100), ccp(400, 300));
	ccDrawCircle(ccp(310, 150), 50, CC_DEGREES_TO_RADIANS(60), 16, YES);
	
	ccDrawColor4F(0.2f, 1.0f, 0.5f, 1.0f);
	ccDrawSolidRect(ccpAdd(sprite5.boundingBox.origin, ccp(200, 50)),
					ccpAdd(sprite5.boundingBox.origin, ccp(100, 200)),
					ccc4f(0.0f, 0.6f, 0.8f, 0.6f));
	
	{
		CGPoint points[4] = {ccp(150, 255), ccp(155, 235), ccp(115, 260), ccp(135, 265)};
		ccDrawSolidPoly(points, 4, ccc4f(0.0f, 1.0f, 0.0f, 0.4f));
	}
	
	ccDrawQuadBezier(ccp(50, 300), ccp(450, 250), ccp(400, 30), 15);
	
	{
		CCPointArray* pointArray = [CCPointArray arrayWithCapacity:5];
		[pointArray addControlPoint:ccp(100, 100)];
		[pointArray addControlPoint:ccp(200, 120)];
		[pointArray addControlPoint:ccp(250, 220)];
		[pointArray addControlPoint:ccp(300, 150)];
		[pointArray addControlPoint:ccp(400, 100)];
		ccDrawColor4F(0.6f, 0.2f, 1.0f, 0.6f);
		ccDrawCatmullRom(pointArray, 40);
	}

	{
		CCPointArray* pointArray = [CCPointArray arrayWithCapacity:5];
		[pointArray addControlPoint:ccp(100, 200)];
		[pointArray addControlPoint:ccp(200, 220)];
		[pointArray addControlPoint:ccp(250, 320)];
		[pointArray addControlPoint:ccp(300, 250)];
		[pointArray addControlPoint:ccp(400, 200)];

		ccDrawColor4F(0.0f, 1.0f, 0.5f, 0.6f);
		ccDrawCardinalSpline(pointArray, 0.1f, 40);
		ccDrawColor4F(1.0f, 0.0f, 0.5f, 0.3f);
		ccDrawCardinalSpline(pointArray, 1.0f, 40);
	}
	 */

	[super visit];
}

@end
