//
//  HelloWorldLayer.h
//  Cocos2D-Performance-Test
//
//  Copyright Steffen Itterheim 2011. Distributed under MIT License.
//

#import "cocos2d.h"
#import "PerfTester.h"

@interface HelloWorldLayer : CCLayer
{
	PerfTester* pt;
	CCNode* testNode;
}

@property (nonatomic, readonly) CCNode* testNode;

+(CCScene *) scene;

+(HelloWorldLayer*) sharedLayer;

@end
