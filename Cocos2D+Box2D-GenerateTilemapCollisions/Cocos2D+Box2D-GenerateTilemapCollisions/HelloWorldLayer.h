//
//  HelloWorldLayer.h
//  Cocos2D+Box2D-GenerateTilemapCollisions
//
//  Created by Steffen Itterheim on 28.05.13.
//  Copyright Steffen Itterheim 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

typedef enum
{
	DebugDrawNone = 0,
	DebugDrawEdges,
	DebugDrawContours,
	DebugDrawPhysics,
	
	DebugDrawMode_Count,
} DebugDrawMode;

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

@class KTEdgeMap;
@class KTContourMap;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
	CCTexture2D *spriteTexture_;
	b2World* world;
	GLESDebugDraw *m_debugDraw;
	CCSpriteBatchNode* _batchNode;
	
	CCTMXTiledMap* _map;
	CCTMXLayer* _tiles;
	KTEdgeMap* _edgeMap;
	KTContourMap* _contourMap;
	
	DebugDrawMode debugDrawMode;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
