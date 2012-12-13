//
//  FakeScrollingScene.h
//  Cocos2D-Scrolling
//
//  Copyright Steffen Itterheim 2012. Distributed under MIT License.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface FakeScrollingLayer : CCLayer
{
	CGSize _screenSize;

    CCSprite* _bg1;
    CCSprite* _bg2;
	
	CCSprite* _player;
}

+(CCScene *) scene;

@end
