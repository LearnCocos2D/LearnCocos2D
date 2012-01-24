//
//  HelloWorldLayer.h
//  Cocos2D-UpdateFilesFromWebServer
//
//  Created by Steffen Itterheim on 24.01.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "cocos2d.h"

enum 
{
	kTagForLocalWebSprites = 1,
	kTagForWorldWideWebSprites,
};

@interface HelloWorldLayer : CCLayer
{
}

+(CCScene *) scene;

@end
