//
//  CCCustomFollow.m
//  Cocos2D-Scrolling
//
//  Copyright Steffen Itterheim 2012. Distributed under MIT License.
//

#import "CCCustomFollow.h"


@implementation CCCustomFollow

// unless you need to modify the world boundaries, the only method you need to override is step:
-(void) step:(ccTime) dt
{
	// If the user has restricted scrolling to a specific size, the boundary is set. Otherwise scrolling is not limited.
	if (boundarySet)
	{
		// If the scrolling world is smaller than the screen size, scrolling is disabled.
		if (boundaryFullyCovered)
		{
			return;
		}
		
		// Scrolling is limited, so after moving the target (the layer containing the followed node) the position is
		// clamped to the boundaries. These boundaries prevent the layer from scrolling too close to a border, because
		// this might reveal the area outside of the world.
		
		// The targetPos coordinate values become more negative the more the followed node moved to the right and up.
		// This is because the layer is moved in the opposite direction of where the followed node is heading.
		CGPoint targetPos = ccpSub(halfScreenSize, followedNode_.position);

		// ensure that temp pos coordinates are within left/right and bottom/top boundary coordinates
		targetPos.x = clampf(targetPos.x, leftBoundary, rightBoundary);
		targetPos.y = clampf(targetPos.y, bottomBoundary, topBoundary);


		// Modification: only start scrolling if targetPos and currentPos are far apart.

		// initialize currentPos once
		if (isCurrentPosValid == NO)
		{
			isCurrentPosValid = YES;
			currentPos = targetPos;
		}

		// if current & target pos are this many points away, scrolling will start following the followed node
		const float kMaxDistanceFromCenter = 120.0f;
		
		float distanceFromCurrentToTargetPos = ccpLength(ccpSub(targetPos, currentPos));
		if (distanceFromCurrentToTargetPos > kMaxDistanceFromCenter)
		{
			// get the delta movement to the last target position
			CGPoint deltaPos = ccpSub(targetPos, previousTargetPos);
			// add the delta to currentPos to track followed node at the distance threshold
			currentPos = ccpAdd(currentPos, deltaPos);

			// Note: this code requires additional steps to ensure the scrolling correctly stops at the world boundary.
			// These steps are not included. This example is to show how you can customize the scrolling behavior by subclassing CCFollow.
			
			//NSLog(@"currentPos: %.1f, %.1f", currentPos.x, currentPos.y);
			[target_ setPosition:currentPos];
		}

		previousTargetPos = targetPos;
	}
	else
	{
		// Scrolling is not limited, simply move the target (the layer containing the followed node) so that the
		// followed node is centered on the screen.
		[target_ setPosition:ccpSub(halfScreenSize, followedNode_.position)];
	}
}



#pragma mark For Reference: CCFollow original methods (the interesting ones)

/*
-(id) initWithTarget:(CCNode *)fNode
{
	if( (self=[super init]) ) {
		
		followedNode_ = [fNode retain];
		boundarySet = FALSE;
		boundaryFullyCovered = FALSE;
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		fullScreenSize = CGPointMake(s.width, s.height);
		halfScreenSize = ccpMult(fullScreenSize, .5f);
	}
	
	return self;
}

-(id) initWithTarget:(CCNode *)fNode worldBoundary:(CGRect)rect
{
	if( (self=[super init]) ) {
		
		followedNode_ = [fNode retain];
		boundarySet = TRUE;
		boundaryFullyCovered = FALSE;
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		fullScreenSize = CGPointMake(winSize.width, winSize.height);
		halfScreenSize = ccpMult(fullScreenSize, .5f);
		
		leftBoundary = -((rect.origin.x+rect.size.width) - fullScreenSize.x);
		rightBoundary = -rect.origin.x ;
		topBoundary = -rect.origin.y;
		bottomBoundary = -((rect.origin.y+rect.size.height) - fullScreenSize.y);
		
		if(rightBoundary < leftBoundary)
		{
			// screen width is larger than world's boundary width
			//set both in the middle of the world
			rightBoundary = leftBoundary = (leftBoundary + rightBoundary) / 2;
		}
		if(topBoundary < bottomBoundary)
		{
			// screen width is larger than world's boundary width
			//set both in the middle of the world
			topBoundary = bottomBoundary = (topBoundary + bottomBoundary) / 2;
		}
		
		if( (topBoundary == bottomBoundary) && (leftBoundary == rightBoundary) )
			boundaryFullyCovered = TRUE;
	}
	
	return self;
}

-(void) step:(ccTime) dt
{
	if(boundarySet)
	{
		// whole map fits inside a single screen, no need to modify the position - unless map boundaries are increased
		if(boundaryFullyCovered)
			return;
		
		CGPoint tempPos = ccpSub( halfScreenSize, followedNode_.position);
		[target_ setPosition:ccp(clampf(tempPos.x,leftBoundary,rightBoundary), clampf(tempPos.y,bottomBoundary,topBoundary))];
	}
	else
		[target_ setPosition:ccpSub( halfScreenSize, followedNode_.position )];
}
*/

@end
