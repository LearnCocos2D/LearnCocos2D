//
//  FakeScrollingScene.h
//  Cocos2D-Scrolling
//
//  Created by Steffen Itterheim on 12.12.12.
//  Copyright 2012 Steffen Itterheim. All rights reserved.
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
