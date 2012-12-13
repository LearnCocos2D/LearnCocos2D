//
//  HelloWorldLayer.h
//  Cocos2D-CoordinateSpaces
//
//  Created by Steffen Itterheim on 06.09.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "cocos2d.h"

static NSString* kPlayerDiedNotification = @"player died";

@interface CustomDrawSprite : CCSprite
-(void) setPositionRelativeToParentPosition:(CGPoint)pos;
@end

@interface CustomLabelTTF : CCLabelTTF
@end

@interface HelloWorldLayer : CCLayer
{
	CCSprite* sprite1;
	CCSprite* sprite2;
	CCSprite* sprite3;
	CCSprite* sprite4;
	CCSprite* sprite5;
	CGPoint touchLocation;
}

+(CCScene *) scene;
+(HelloWorldLayer*) sharedMyScene;

@end
