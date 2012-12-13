/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"

/** Removes the target from its parent node. Can be used to conveniently detach a node from the scene hierarchy at the end of a CCSequence. */
@interface CCRemoveFromParentAction : CCActionInstant
@end

@interface Curve : CCNode
@property (nonatomic) float radius;
@property float circumference;
@end

@interface HelloWorldLayer : CCLayer
{
	CCSprite* axle1;
	CCSprite* axle2;
	float axle1Angle;
	float axle2Angle;
	
	float axleDistance;
	CGPoint axleDistances;
	
	CCSprite* lok;
	
	Curve* curve;
	Curve* curve2;
	
	float speed;	// pixels per frame
	
	BOOL isRotating1;
	BOOL invertSpeed1;
	BOOL isRotating2;
	BOOL invertSpeed2;
	BOOL invertLokRotation;

	CCSpriteBatchNode* dotBatch;
	CCMotionStreak* streak;
}

+(id) scene;

@end
