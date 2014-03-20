//
//  CCSprite+QuickLook.m
//  Cocos2D-QuickLookExample
//
//  Created by Steffen Itterheim on 20/03/14.
//

#import "CCSprite+QuickLook.h"
#import "cocos2d.h"

@implementation CCSprite (QuickLook)

-(id) debugQuickLookObject
{
	if (arc4random_uniform(3) > 0)
	{
		// return the view itself
		return [CCDirector sharedDirector].view;
	}
	
	// you could also just return the object's description string
	return [self debugDescription];
}

@end
