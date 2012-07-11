/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "HelloWorldLayer.h"



/*
 
 WARNING: this is pretty crappy, hacked code. It works, but there's a couple stupid things here.
 For example, there's separate code handling both axles, and duplicate variables for each. This needs
 to be factored out into Axle classes, and both axles be put into a RailCar class. Otherwise you'll have
 a hell of a bad time trying to make an actual train with multiple cars.
 
 The oval track is hardcoded, and pretty ugly speed is inverted to make the car go backwards, but also
 to fix the cornering of the car so that the rotation is correct. I didn't use a velocity vector, just speed.
 Without velocity, I can't derive in which direction the car goes, so that's hardcoded and needs to be fixed.
 
 There's debugging code inlined with the rest of the code. There's everything put into one class. There's hardly
 anything factored out into meaningful methods. All of that is bad.
 
 Some terribly abbreviated variable names. I normally don't speak such C-programmer's gibberish.
 
 Memory management wasn't considered since this project code originated from an ARC-enabled project.
 
 */

@implementation CCRemoveFromParentAction
-(void) startWithTarget:(id)target
{
	[super startWithTarget:target];
	[target removeFromParentAndCleanup:YES];
}
@end


@implementation Curve
@synthesize radius, circumference;
-(void) setRadius:(float)r
{
	radius = r;
	circumference = 2 * M_PI * radius;
}
-(id) init
{
	self = [super init];
	if (self)
	{
		CCSprite* s = [CCSprite spriteWithFile:@"Icon.png"];
		s.color = ccGREEN;
		s.scale = 0.2f;
		[self addChild:s];
	}
	return self;
}
@end


@interface HelloWorldLayer (PrivateMethods)
@end

@implementation HelloWorldLayer

+(id) scene
{
	CCScene* scene = [CCScene node];
	HelloWorldLayer* layer = [[HelloWorldLayer alloc] init];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		glClearColor(0.1f, 0.1f, 0.3f, 1.0f);
		
		axleDistance = 100;
		axleDistances = CGPointMake(axleDistance, axleDistance);
		
		axle1 = [CCSprite spriteWithFile:@"Icon.png"];
		axle1.position = CGPointMake(200 + axleDistance, 100);
		axle1.scale = 0.3f;
		[self addChild:axle1];
		
		axle2 = [CCSprite spriteWithFile:@"Icon.png"];
		axle2.position = CGPointMake(200, 100);
		axle2.scale = axle1.scale;
		[self addChild:axle2];
		
		// pixels per frame
		speed = 1.431f;
		axle1Angle = 270;
		axle2Angle = 270;
		
		curve = [[Curve alloc] init];
		curve.radius = 100;
		curve.position = CGPointMake(380, 200 - (100 - curve.radius));
		[self addChild:curve];
		
		curve2 = [[Curve alloc] init];
		curve2.radius = curve.radius;
		curve2.position = CGPointMake(180, curve.position.y);
		[self addChild:curve2];
		
		lok = [CCSprite spriteWithFile:@"lok1.png"];
		lok.flipX = YES;
		lok.position = CGPointMake(300, 250);
		[self addChild:lok z:1];
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(CGPoint) getPointOnCircleWithRadius:(float)radius angle:(float)angleInDegrees origin:(CGPoint)origin
{
	float xr = radius * cosf(CC_DEGREES_TO_RADIANS(angleInDegrees)) + origin.x;
	float yr = radius * sinf(CC_DEGREES_TO_RADIANS(angleInDegrees)) + origin.y;
	
	return CGPointMake(xr, yr);
}

-(void) update:(ccTime)delta
{
	if (isRotating1)
	{
		Curve* currentCurve = curve;
		if (axle1.position.x <= curve2.position.x) 
		{
			currentCurve = curve2;
			invertSpeed1 = NO;
			invertLokRotation = YES;
		}
		
		// v = w * r
		// w = v / r
		// angular velocity w is speed divided by radius
		float w = speed / currentCurve.radius;
		//LOG_EXPR(CC_RADIANS_TO_DEGREES(w));
		axle1.rotation -= CC_RADIANS_TO_DEGREES(w);
		axle1Angle += CC_RADIANS_TO_DEGREES(w);
		
		// acceleration a is speed squared divided by radius
		float a = (speed * speed) / currentCurve.radius;
		//LOG_EXPR(a);
		// same as:
		a = currentCurve.radius * (w * w);
		
		CGPoint curvePos = [self getPointOnCircleWithRadius:currentCurve.radius angle:axle1Angle origin:currentCurve.position];
		axle1.position = curvePos;
	}
	else
	{
		CGPoint pos = axle1.position;
		if (invertSpeed1)
			pos.x -= speed;
		else 
			pos.x += speed;
		
		axle1.position = pos;
	}
	
	isRotating1 = (axle1.position.x >= curve.position.x || axle1.position.x <= curve2.position.x);
	invertSpeed1 = (isRotating1 || invertSpeed1);
	
	
	// Axle #2
	if (isRotating2)
	{
		Curve* currentCurve = curve;
		if (axle2.position.x <= curve2.position.x) 
		{
			currentCurve = curve2;
			invertSpeed2 = NO;
			invertLokRotation = YES;
		}
		
		// v = w * r
		// w = v / r
		// angular velocity w is speed divided by radius
		float w = speed / currentCurve.radius;
		//LOG_EXPR(CC_RADIANS_TO_DEGREES(w));
		axle2.rotation -= CC_RADIANS_TO_DEGREES(w);
		axle2Angle += CC_RADIANS_TO_DEGREES(w);
		
		// acceleration a is speed squared divided by radius
		float a = (speed * speed) / currentCurve.radius;
		//LOG_EXPR(a);
		// same as:
		a = currentCurve.radius * (w * w);
		
		CGPoint curvePos = [self getPointOnCircleWithRadius:currentCurve.radius angle:axle2Angle origin:currentCurve.position];
		axle2.position = curvePos;
	}
	else
	{
		CGPoint pos = axle2.position;
		if (invertSpeed2)
			pos.x -= speed;
		else 
			pos.x += speed;
		
		axle2.position = pos;
	}
	
	isRotating2 = (axle2.position.x >= curve.position.x || axle2.position.x <= curve2.position.x);
	invertSpeed2 = (isRotating2 || invertSpeed2);
	
	
	if (isRotating1 == NO && isRotating2 == NO)
	{
		invertLokRotation = NO;
	}
	
	
	CGPoint axlesVector = ccpSub(axle2.position, axle1.position);
	CGPoint axleMidPoint = ccpAdd(axle1.position, ccpMult(axlesVector, 0.5f));
	lok.position = axleMidPoint;
	
	const CGPoint originVector = CGPointMake(1, 0);
	float t = ccpDot(originVector, axlesVector);
	float l1 = ccpLength(axlesVector);
	float l2 = ccpLength(originVector);
	float a = acosf(t / (l1 * l2));
	if (invertLokRotation)
	{
		a *= -1.0f;
	}
	
	lok.rotation = CC_RADIANS_TO_DEGREES(a);
	
	// LOG min/max deviation of axle distance
	if (l1 < axleDistances.x) 
	{
		axleDistances.x = l1;
		CCLOG(@"MIN axle deviation: %.2f", l1 - axleDistance);
	}
	if (l1 > axleDistances.y) 
	{
		axleDistances.y = l1;
		CCLOG(@"MAX axle deviation: %.2f", l1 - axleDistance);
	}
	
	
	
	// tracking dots
	CCSprite* s = [CCSprite spriteWithFile:@"Icon.png"];
	s.scale = 0.1f;
	s.color = ccYELLOW;
	s.position = axle1.position;
	[self addChild:s z:-1];
	
	id wait = [CCDelayTime actionWithDuration:15];
	id remove = [CCRemoveFromParentAction action];
	id sequence = [CCSequence actions:wait, remove, nil];
	[s runAction:sequence];
	
	s = [CCSprite spriteWithFile:@"Icon.png"];
	s.scale = 0.05f;
	s.color = ccMAGENTA;
	s.position = lok.position;
	[self addChild:s z:-2];
	
	wait = [CCDelayTime actionWithDuration:15];
	remove = [CCRemoveFromParentAction action];
	sequence = [CCSequence actions:wait, remove, nil];
	[s runAction:sequence];
}

@end
