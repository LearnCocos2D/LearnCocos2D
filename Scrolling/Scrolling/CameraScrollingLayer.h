//
//  CameraScrollingLayer.h
//  Cocos2D-Scrolling
//
//  Copyright Steffen Itterheim 2012. Distributed under MIT License.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CameraScrollingLayer : CCLayer
{
	CGSize _screenSize;
	CGSize _worldSize;
	
	CCSprite* _player;
	CCSpriteBatchNode* _enemyBatch;
}

+(CCScene *) scene;

@end
