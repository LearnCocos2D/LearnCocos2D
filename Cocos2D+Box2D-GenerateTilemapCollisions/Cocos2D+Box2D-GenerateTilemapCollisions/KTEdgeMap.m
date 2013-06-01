//
//  KTEdgeMap.m
//  Cocos2D+Box2D-GenerateTilemapCollisions
//
//  Created by Steffen Itterheim on 29.05.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KTEdgeMap.h"
#import "VTPG_Common.h"


// the tile GID of a tile which represents collisions
// a better solution would be to allow multiple blocking GIDs and/or check each tile's properties
static uint32_t kBlockingGID = 150;


@implementation KTEdgeMap

+(id) edgeMapFromTileLayer:(CCTMXLayer*)layer
{
	return [[self alloc] initFromTileLayer:layer];
}

-(id) initFromTileLayer:(CCTMXLayer*)layer
{
	self = [super init];
	if (self)
	{
		_layer = layer;
		
		[self initEdgeMap];
		[self generateEdges];
		
		_layer = nil;
	}
	return self;
}

-(void) dealloc
{
	[self freeEdgeMap];
}

-(void) initEdgeMap
{
	CGSize layerSize = _layer.layerSize;
	// init the edge indices array
	NSUInteger numEdges = layerSize.width * layerSize.height;
	// free ensures the function is reentrent, correctly replacing any previously existing array
	[self freeEdgeMap];
	// calloc ensures the array is initialized with zeros
	_edges = calloc(numEdges, sizeof(KTEdges));
}

-(void) freeEdgeMap
{
	free(_edges);
	_edges = nil;
}

-(void) generateEdges
{
	CGSize layerSize = _layer.layerSize;
	NSUInteger index = 0, rowIndex = 0;

	for (NSInteger y = 0; y < layerSize.height; y++)
	{
		rowIndex = y * layerSize.width;
		
		for (NSInteger x = 0; x < layerSize.width; x++)
		{
			uint32_t myGID = [_layer tileGIDAt:CGPointMake(x, y)];

			// find edges of tile
			KTEdges edges = KTEdgeNone;
			
			// LEFT SIDE
			uint32_t gid = (x > 0 && y < layerSize.height) ? [_layer tileGIDAt:CGPointMake(x - 1, y)] : kBlockingGID;
			if ((myGID == kBlockingGID && gid != kBlockingGID) || (myGID != kBlockingGID && gid == kBlockingGID))
			{
				edges |= KTEdgesLeftSide;
			}
			// RIGHT SIDE
			gid = (x < layerSize.width - 1 && y < layerSize.height) ? [_layer tileGIDAt:CGPointMake(x + 1, y)] : kBlockingGID;
			if ((myGID == kBlockingGID && gid != kBlockingGID) || (myGID != kBlockingGID && gid == kBlockingGID))
			{
				edges |= KTEdgesRightSide;
			}
			// TOP SIDE
			gid = (y > 0 && x < layerSize.width) ? [_layer tileGIDAt:CGPointMake(x, y - 1)] : kBlockingGID;
			if ((myGID == kBlockingGID && gid != kBlockingGID) || (myGID != kBlockingGID && gid == kBlockingGID))
			{
				edges |= KTEdgesTopSide;
			}
			// BOTTOM SIDE
			gid = (y < layerSize.height - 1 && x < layerSize.width) ? [_layer tileGIDAt:CGPointMake(x, y + 1)] : kBlockingGID;
			if ((myGID == kBlockingGID && gid != kBlockingGID) || (myGID != kBlockingGID && gid == kBlockingGID))
			{
				edges |= KTEdgesBottomSide;
			}

			index = rowIndex + x;
			_edges[index] = edges;
			
			//LOG_EXPR(CGPointMake(x, y));
			//LOG_EXPR(_edges[index]);
		}
	}
}

// Test for edges of a tile coord.
// If the tile coord is a blocking tile, checks for non-blocking surrounding tiles and vice versa.
// Out of bounds tiles are considered blocking.
-(KTEdges) edgesForTileAt:(CGPoint)pos
{
	KTEdges edges = KTEdgeNone;
	NSInteger x = pos.x;
	NSInteger y = pos.y;
	CGSize layerSize = _layer.layerSize;

	// pos out of bounds, return no edges
	if (x < 0 || y < 0 || x >= layerSize.width || y >= layerSize.height)
	{
		NSLog(@"edgesForTileAt:{%d, %d} tile coord out of bounds", x, y);
		return edges;
	}

	const uint32_t kBlockingGID = 150;
	uint32_t myGID = [_layer tileGIDAt:CGPointMake(x, y)];

	// LEFT SIDE
	uint32_t gid = (x > 0) ? [_layer tileGIDAt:CGPointMake(x - 1, y)] : kBlockingGID;
	if ((myGID == kBlockingGID && gid != kBlockingGID) || (myGID != kBlockingGID && gid == kBlockingGID))
	{
		edges |= KTEdgesLeftSide;
	}
	// RIGHT SIDE
	gid = (x < layerSize.width - 1) ? [_layer tileGIDAt:CGPointMake(x + 1, y)] : kBlockingGID;
	if ((myGID == kBlockingGID && gid != kBlockingGID) || (myGID != kBlockingGID && gid == kBlockingGID))
	{
		edges |= KTEdgesRightSide;
	}
	// TOP SIDE
	gid = (y < layerSize.height - 1) ? [_layer tileGIDAt:CGPointMake(x, y + 1)] : kBlockingGID;
	if ((myGID == kBlockingGID && gid != kBlockingGID) || (myGID != kBlockingGID && gid == kBlockingGID))
	{
		edges |= KTEdgesTopSide;
	}
	// BOTTOM SIDE
	gid = (y > 0) ? [_layer tileGIDAt:CGPointMake(x, y - 1)] : kBlockingGID;
	if ((myGID == kBlockingGID && gid != kBlockingGID) || (myGID != kBlockingGID && gid == kBlockingGID))
	{
		edges |= KTEdgesBottomSide;
	}
	
	return edges;
}

@end
