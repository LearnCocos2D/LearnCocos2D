//
//  KTEdgeMap.h
//  Cocos2D+Box2D-GenerateTilemapCollisions
//
//  Created by Steffen Itterheim on 29.05.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum : uint8_t
{
	KTEdgeTopLeft = 1 << 0,
	KTEdgeTopRight = 1 << 1,
	KTEdgeBottomLeft = 1 << 2,
	KTEdgeBottomRight = 1 << 3,
	
	KTEdgeNone = 0,
	KTEdgesAll = KTEdgeTopLeft | KTEdgeTopRight | KTEdgeBottomLeft | KTEdgeBottomRight,
	KTEdgesLeftSide = KTEdgeTopLeft | KTEdgeBottomLeft,
	KTEdgesRightSide = KTEdgeTopRight | KTEdgeBottomRight,
	KTEdgesTopSide = KTEdgeTopLeft | KTEdgeTopRight,
	KTEdgesBottomSide = KTEdgeBottomLeft | KTEdgeBottomRight,
} KTEdges;

typedef struct
{
	CGPoint start;
	CGPoint end;
} KTSegment;

@interface KTEdgeMap : NSObject
{
	@private
	__weak CCTMXLayer* _layer;
}

@property (nonatomic, readonly) CGSize edgeMapSize;
@property (nonatomic, readonly) KTEdges* edges;

+(id) edgeMapFromTileLayer:(CCTMXLayer*)layer;

-(void) freeEdgeMap;

@end
