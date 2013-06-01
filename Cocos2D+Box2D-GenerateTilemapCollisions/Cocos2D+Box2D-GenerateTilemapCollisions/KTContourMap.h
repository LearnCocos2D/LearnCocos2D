//
//  KTContourMap.h
//  Cocos2D+Box2D-GenerateTilemapCollisions
//
//  Created by Steffen Itterheim on 29.05.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class KTIntegerArray;
@class KTPointArray;

typedef enum
{
	KTNeighborLeft,
	KTNeighborUpLeft,
	KTNeighborUp,
	KTNeighborUpRight,
	KTNeighborRight,
	KTNeighborDownRight,
	KTNeighborDown,
	KTNeighborDownLeft,
	
} KTNeighborIndices;

@interface KTContourTiles : NSObject
@end


@interface KTContourMap : NSObject
{
	@private
	__weak CCTMXLayer* _layer;
	CGSize _tileSize;
	CGSize _layerSize;

	NSMutableArray* _contours;
	NSMutableArray* _contourSegments;
	NSUInteger _blockMapCount;
	CGSize _blockMapSize;
	uint16_t* _blockMap;
	BOOL _mapBorderBlocking;
}

/** Contains KTIntegerArray each defining the indixes of a single contour. */
@property (nonatomic, readonly) NSArray* contours;
/** Contains KTPointArray of points definining a single contour's line segments. */
@property (nonatomic, readonly) NSArray* contourSegments;

+(id) contourMapFromTileLayer:(CCTMXLayer*)layer;

@end
