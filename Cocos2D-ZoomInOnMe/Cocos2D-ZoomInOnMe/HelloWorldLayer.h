//
//  HelloWorldLayer.h
//  Cocos2D-ZoomInOnMe
//
//  Created by Steffen Itterheim on 17.05.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "cocos2d.h"

@interface HelloWorldLayer : CCLayer
{
	CCSprite* player;
	BOOL isZooming;
}

+(CCScene *) scene;

@end
