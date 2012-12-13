//
//  FollowScrollingLayer.h
//  Cocos2D-Scrolling
//
//  Created by Steffen Itterheim on 12.12.12.
//  Copyright 2012 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface FollowScrollingLayer : CCLayer
{
	CGSize _screenSize;
	CGSize _worldSize;
	
	CCSprite* _player;
	CCSpriteBatchNode* _enemyBatch;
}

+(CCScene *) scene;

@end
