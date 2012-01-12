/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "ccMoreMacros.h"

/** extends CCNode */
@interface CCNode (KoboldExtensions)


/** Returns true if the point is contained in (is on) the node. Respects rotation and scaling of the node. */
-(BOOL) containsPoint:(CGPoint)point;

#if KK_PLATFORM_IOS
/** Returns true if the UITouch is contained in (is on) the node. Respects rotation and scaling of the node. */
-(BOOL) containsTouch:(UITouch*)touch;
#endif


-(BOOL) intersectsNode:(CCNode*)other;


/** Calls the node's "node" method to initialize it, then adds it to a CCScene object and returns that CCScene.
 Useful as a convenience method for creating a CCLayer instance wrapped in a scene, so that you can write:
 
 [[CCDirector sharedDirector] replaceScene:[MyGameLayer nodeWithScene]];
 */
+(id) nodeWithScene;

@end
