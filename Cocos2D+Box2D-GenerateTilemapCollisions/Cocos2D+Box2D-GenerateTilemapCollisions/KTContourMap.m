//
//  KTContourMap.m
//  Cocos2D+Box2D-GenerateTilemapCollisions
//
//  Created by Steffen Itterheim on 29.05.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import "KTContourMap.h"
#import "KTPointArray.h"
#import "KTIntegerArray.h"
#import "VTPG_Common.h"

// the tile GID of a tile which represents collisions
// a better solution would be to allow multiple blocking GIDs and/or check each tile's properties
const uint32_t kBlockingGID = 150;

const uint16_t kBlockMapBorder = 0xffff;

static NSInteger neighborOffsets[8];


@implementation KTContourMap

+(id) contourMapFromTileLayer:(CCTMXLayer*)layer
{
	return [[self alloc] initFromTileLayer:layer];
}

-(id) initFromTileLayer:(CCTMXLayer*)layer
{
	self = [super init];
	if (self)
	{
		_layer = layer;

		// map borders (tiles outside of map boundary) are considered blocking
		_mapBorderBlocking = YES;
		_tileSize = _layer.tileset.tileSize;
		_layerSize = _layer.layerSize;
		
		_contours = [NSMutableArray arrayWithCapacity:10];
		_contourSegments = [NSMutableArray arrayWithCapacity:10];
		[self traceContours];
		
		_layer = nil;
	}
	return self;
}

-(void) dealloc
{
	[self freeBlockMap];
}

-(void) traceContours
{
	[self createBlockMap];
	[self dumpBlockMap];
	
	// offset indices (relative to a certain tile) in clockwise order, beginning with the tile to the left
	neighborOffsets[0] = -1;
	neighborOffsets[1] = -(_blockMapSize.width + 1);
	neighborOffsets[2] = -_blockMapSize.width;
	neighborOffsets[3] = -(_blockMapSize.width - 1);
	neighborOffsets[4] = 1;
	neighborOffsets[5] = _blockMapSize.width + 1;
	neighborOffsets[6] = _blockMapSize.width;
	neighborOffsets[7] = _blockMapSize.width - 1;
	
	NSLog(@"Moore neighbor tracing begins ...");
	
	// unique ID for each contour for the blocking map (1 is regular, untraced blocking, 0 is free tile)
	NSUInteger contourBlockID = 2;
	NSUInteger currentTile = [self nextTileStartingAt:[self nextTileStartingAt:0 blocking:NO] blocking:YES];
	
	// TODO:
	// find a surrounding free block from blocking tile, if none found search for next block tile
	// if free block found, use that free block as initial backtrack tile
	
	// trace A contour, something's wrong at around 0,4
	
	while (currentTile != 0)
	{
		// find first non-blocking tile, then find first blocking tile after that
		NSUInteger boundaryTile = currentTile;
		NSLog(@"Initial boundary at : %@", [self coordStringFromIndex:boundaryTile]);
		
		// first backtrack tile is the one to the left
		NSUInteger backtrackTile = [self firstFree4WayNeighborForTile:boundaryTile];
		if (backtrackTile == 0)
		{
			// start again
			NSLog(@"\tSelected boundary has no surrounding free tiles, skipping.");
			currentTile = [self nextTileStartingAt:[self nextTileStartingAt:currentTile blocking:NO] blocking:YES];
			continue;
		}
		NSLog(@"Initial backtrack at: %@", [self coordStringFromIndex:backtrackTile]);
		
		// get the first Moore neighbor tile
		KTNeighborIndices initialBacktrackNeighborIndex = [self neighborIndexForBoundary:boundaryTile backtrack:backtrackTile];
		KTNeighborIndices neighborIndex = initialBacktrackNeighborIndex + 1;
		NSUInteger neighborTestCount = 1;
		NSUInteger neighborTile = boundaryTile + neighborOffsets[neighborIndex];
		NSLog(@"Initial neighbor at: %@ %@", [self coordStringFromIndex:neighborTile], [self nameForNeighborIndex:neighborIndex]);
		
		// remember the start tile and the tile it was entered from (backtrack) for the termination condition
		NSUInteger startTileVisitCount = 0;
		NSUInteger contourStartTile = boundaryTile;
		NSUInteger backtrackStartTile = backtrackTile;
		
		// create tile index array and add the first contour tile to it
		KTIntegerArray* contourTiles = [KTIntegerArray integerArrayWithCapacity:8];
		[_contours addObject:contourTiles];
		[contourTiles addInteger:contourStartTile];
		
		// create segments array
		KTPointArray* contourSegment = [KTPointArray pointArrayWithCapacity:8];
		[_contourSegments addObject:contourSegment];
		
		[self dumpBlockMap];
		NSLog(@"BEGIN LOOP .......");
		
		while (YES)
		{
			//NSLog(@"neighbor: %@ [%@] - BLOCKING: %@", [self coordStringFromIndex:neighborTile], [self nameForNeighborIndex:neighborIndex], _blockMap[neighborTile] ? @"YES" : @"NO");
			
			// is the current neighbor tile blocking?
			if (_blockMap[neighborTile])
			{
				[self addPointsToSegments:contourSegment boundary:boundaryTile fromNeighborIndex:initialBacktrackNeighborIndex toNeighborIndex:neighborIndex];

				// mark the field as traced
				_blockMap[neighborTile] = contourBlockID;
				
				boundaryTile = neighborTile;
				[contourTiles addInteger:boundaryTile];
				//NSLog(@"\tNew BOUNDARY at: %@", [self coordStringFromIndex:boundaryTile]);
				//NSLog(@"\tBacktracking to: %@", [self coordStringFromIndex:backtrackTile]);
				
				// (backtrack: move the current pixel c to the pixel from which p was entered)
				initialBacktrackNeighborIndex = [self neighborIndexForBoundary:boundaryTile backtrack:backtrackTile];
				neighborIndex = (initialBacktrackNeighborIndex + 1) % 8;
				neighborTestCount = 0;
				neighborTile = boundaryTile + neighborOffsets[neighborIndex];
				//NSLog(@"\tNew neighbor at : %@ %@", [self coordStringFromIndex:neighborTile], [self nameForNeighborIndex:neighborIndex]);
				
				// uncomment this and set a breakpoint to see the map tracing contours tile after tile
				//[self dumpBlockMap];
			}
			else
			{
				// did we loop around a single blocking tile once?
				if (neighborTestCount == 7)
				{
					NSLog(@"Found single block tile at %@", [self coordStringFromIndex:boundaryTile]);
					break;
				}
				
				// (advance the current pixel c to the next clockwise pixel in M(p) and update backtrack)
				backtrackTile = neighborTile;
				neighborIndex = (neighborIndex + 1) % 8;
				neighborTile = boundaryTile + neighborOffsets[neighborIndex];
				neighborTestCount++;
			}
			
			if (neighborTile == contourStartTile)
			{
				startTileVisitCount++;
				if (startTileVisitCount > 2 || backtrackTile == backtrackStartTile)
				{
					NSLog(@"Returned to starting boundary, quitting!");
					//NSLog(@"\ttart tile at: %@", [self coordStringFromIndex:contourStartTile]);
					//NSLog(@"\tbacktrack at: %@", [self coordStringFromIndex:backtrackStartTile]);
					break;
				}
			}
		}

		// add the remaining segments
		[self addPointsToSegments:contourSegment boundary:boundaryTile fromNeighborIndex:initialBacktrackNeighborIndex toNeighborIndex:neighborIndex];
		[self closeContour:contourSegment];

		// dump the newly added contour and remaining blocking tiles
		[self dumpBlockMap];

		// find the next free tile and trace that
		currentTile = [self nextTileStartingAt:[self nextTileStartingAt:currentTile blocking:NO] blocking:YES];
		contourBlockID++;
	}

	NSLog(@"Exiting, all tiles processed.");
}

-(void) addPointsToSegments:(KTPointArray*)segments boundary:(NSUInteger)boundaryTile fromNeighborIndex:(KTNeighborIndices)fromNeighbor toNeighborIndex:(KTNeighborIndices)toNeighbor
{
	CGPoint boundaryCoords = [self tileCoordForBlockMapIndex:boundaryTile];
	boundaryCoords.y = _layerSize.height - 1 - boundaryCoords.y;

	for (KTNeighborIndices neighbor = fromNeighbor; neighbor != toNeighbor; neighbor = (neighbor + 1) % 8)
	{
		BOOL isPointValid = YES;
		CGPoint newPoint;
		
		switch (neighbor)
		{
			case KTNeighborLeft:
				newPoint = CGPointMake(boundaryCoords.x * _tileSize.width, boundaryCoords.y * _tileSize.height);
				break;
			case KTNeighborUp:
				newPoint = CGPointMake(boundaryCoords.x * _tileSize.width, boundaryCoords.y * _tileSize.height + _tileSize.height);
				break;
			case KTNeighborRight:
				newPoint = CGPointMake(boundaryCoords.x * _tileSize.width + _tileSize.width, boundaryCoords.y * _tileSize.height + _tileSize.height);
				break;
			case KTNeighborDown:
				newPoint = CGPointMake(boundaryCoords.x * _tileSize.width + _tileSize.width, boundaryCoords.y * _tileSize.height);
				break;
				
			default:
				// diagonal neighbors don't add any points
				isPointValid = NO;
				break;
		}

		if (isPointValid)
		{
			if (segments.count >= 2)
			{
				// check if the new point is on the same segment (axis) as the last two points
				CGPoint segmentStart = segments.points[segments.count - 2];
				CGPoint segmentEnd = segments.points[segments.count - 1];
				if ([self isPointOnSameLine:newPoint segmentStart:segmentStart segmentEnd:segmentEnd])
				{
					// replace previous segment's end point
					segments.points[segments.count -1] = newPoint;
				}
				else
				{
					// add as new point
					[segments addPoint:newPoint];
				}
			}
			else
			{
				// first two points are always added unconditionally
				[segments addPoint:newPoint];
			}
		}
	}
}

-(void) closeContour:(KTPointArray*)segments
{
	// some contours may be traced more than once, find and remove repeating patterns
	NSUInteger sequenceLength = 0;
	NSUInteger compareCount = 0;
	CGPoint firstPoint = segments.points[0];
	for (NSUInteger i = 1; i < segments.count; i++)
	{
		CGPoint point = segments.points[i];

		if (sequenceLength)
		{
			CGPoint comparePoint = segments.points[i - sequenceLength];
			if (CGPointEqualToPoint(point, comparePoint))
			{
				// the pattern is repeating so far
				compareCount++;
			}
			else
			{
				// false alarm, sometimes the first point may be visited again without repeat
				sequenceLength = 0;
				compareCount = 0;
			}
			
			// did we match an entire repeating sequence once?
			if (sequenceLength > 0 && compareCount == sequenceLength)
			{
				// remove all the repeating points
				[segments removePointsStartingAtIndex:sequenceLength];
				break;
			}
		}
		
		// try to find the first point again
		if (sequenceLength == 0 && CGPointEqualToPoint(point, firstPoint))
		{
			// now all following points must match sequenceLength times, then it is a repeating pattern
			sequenceLength = i;
		}
	}

	// ensure that first and last point are not equal
	CGPoint lastPoint = [segments lastPoint];
	if (CGPointEqualToPoint(firstPoint, lastPoint))
	{
		// remove the last point
		[segments removeLastPoint];
	}
	
	// check if the first two points' segment and the last point are on the same line
	if (segments.count >= 3)
	{
		CGPoint lastPoint = [segments lastPoint];
		CGPoint segmentStart = segments.points[1];
		CGPoint segmentEnd = segments.points[0];
		if ([self isPointOnSameLine:lastPoint segmentStart:segmentStart segmentEnd:segmentEnd])
		{
			// first point becomes the last point, and the last point deleted
			segments.points[0] = lastPoint;
			[segments removeLastPoint];
		}
		
		// test if the second to last and last point are on the same line as the first point
		segmentStart = segments.points[segments.count - 2];
		segmentEnd = [segments lastPoint];
		if ([self isPointOnSameLine:firstPoint segmentStart:segmentStart segmentEnd:segmentEnd])
		{
			[segments removeLastPoint];
		}
	}

	// ensure that last point equals first point to close the shape
	firstPoint = segments.points[0];
	lastPoint = [segments lastPoint];
	if (CGPointEqualToPoint(firstPoint, lastPoint) == NO)
	{
		// add the first point again to close the segment chain
		[segments addPoint:firstPoint];
	}
}

-(BOOL) isPointOnSameLine:(CGPoint)point segmentStart:(CGPoint)segmentStart segmentEnd:(CGPoint)segmentEnd
{
	return (segmentStart.x == segmentEnd.x && segmentStart.x == point.x) || (segmentStart.y == segmentEnd.y && segmentStart.y == point.y);
}

// returns the neighbor index between these two tiles
// ie if the backtrack is to the left of boundary, index == 0
-(KTNeighborIndices) neighborIndexForBoundary:(NSUInteger)boundaryTile backtrack:(NSUInteger)backtrackTile
{
	KTNeighborIndices index = 0;
	for (; index < 8; index++)
	{
		if (boundaryTile + neighborOffsets[index] == backtrackTile)
		{
			break;
		}
	}
	
	//NSLog(@"\tn-idx: %u (%@) for %@ => %@", index, [self nameForNeighborIndex:index], [self coordStringFromIndex:boundaryTile], [self coordStringFromIndex:backtrackTile]);
	
	return index;
}

-(void) createBlockMap
{
	// free ensures the function is reentrent, correctly replacing any previously existing array
	[self freeBlockMap];

	// calloc ensures the array is initialized with zeros
	// this could be a bitarray to conserve memory
	NSUInteger width = _layerSize.width + 2;
	NSUInteger height = _layerSize.height + 2;
	_blockMapSize = CGSizeMake(width, height);
	_blockMapCount = width * height;
	_blockMap = calloc(_blockMapCount, sizeof(uint16_t));
	
	for (NSInteger y = 0; y < _blockMapSize.height; y++)
	{
		for (NSInteger x = 0; x < _blockMapSize.width; x++)
		{
			if (x == 0 || y == 0 || x > _layerSize.width || y > _layerSize.height)
			{
				// the outer borders contain a special blocking bit
				if (_mapBorderBlocking)
				{
					_blockMap[y * width + x] = kBlockMapBorder;
				}
			}
			else
			{
				// test the tile at the given (tilemap) coord and see if it's blocking or not
				uint32_t myGID = [_layer tileGIDAt:CGPointMake(x - 1, y - 1)];
				if (myGID == kBlockingGID)
				{
					_blockMap[y * width + x] = YES;
				}
			}
		}
	}
}

-(void) freeBlockMap
{
	free(_blockMap);
	_blockMap = nil;
}

-(BOOL) isOutOfBoundsTile:(NSUInteger)index
{
	// skip all tiles at the outer boundary
	CGPoint pos = [self tileCoordForBlockMapIndex:index];
	return (pos.x < 0 || pos.y < 0 || pos.x == _blockMapSize.width - 2 || pos.y == _blockMapSize.height - 2);
}

-(NSUInteger) firstFree4WayNeighborForTile:(NSUInteger)tile
{
	// test the 4-way connected tiles and return the first free one, or 0 if there's none
	NSUInteger freeTile = 0;
	for (NSUInteger i = 0; i < 8; i += 2)
	{
		NSUInteger testTile = tile + neighborOffsets[i];
		if ([self isOutOfBoundsTile:testTile])
		{
			continue;
		}
		
		CGPoint coord = [self tileCoordForBlockMapIndex:testTile];
		uint32_t gid = [_layer tileGIDAt:coord];
		
		if (gid != kBlockingGID)
		{
			freeTile = testTile;
			break;
		}
	}
	
	return freeTile;
}

-(NSUInteger) nextTileStartingAt:(NSUInteger)index blocking:(BOOL)blocking
{
	for (NSInteger i = index; i < _blockMapCount; i++)
	{
		// skip all tiles at the outer boundary
		if (_blockMap[i] == kBlockMapBorder)
		{
			continue;
		}
		
		if ((blocking == NO && _blockMap[i] == 0) || (blocking && _blockMap[i] == 1))
		{
			/*
			if (blocking)
				NSLog(@"Found untracted BLOCK tile at: %@", [self coordStringFromIndex:i]);
			else
				NSLog(@"Found   FREE    tile    at   : %@", [self coordStringFromIndex:i]);
			 */
			
			return i;
		}
	}
	
	return 0;
}

-(CGPoint) tileCoordForIndex:(NSUInteger)index
{
	NSUInteger width = _layerSize.width;
	return CGPointMake(index % width, index / width);
}

-(CGPoint) tileCoordForBlockMapIndex:(NSUInteger)index
{
	NSUInteger width = _blockMapSize.width;
	return CGPointMake((NSInteger)(index % width) - 1, (NSInteger)(index / width) - 1);
}


#pragma mark DEBUG Helper

// shorthand for better debug output
-(CGPoint) coord:(NSUInteger)index
{
	return [self tileCoordForBlockMapIndex:index];
}

-(NSString*) coordStringFromIndex:(NSUInteger)index
{
	CGPoint coord = [self coord:index];
	return [NSString stringWithFormat:@"[%u]=(%.0f,%.0f)", index, coord.x, coord.y];
}

-(NSString*) nameForNeighborIndex:(KTNeighborIndices)index
{
	NSString* name;
	
	switch (index)
	{
		case KTNeighborLeft:
			name = @"LEFT";
			break;
		case KTNeighborUpLeft:
			name = @"UPLEFT";
			break;
		case KTNeighborUp:
			name = @"UP";
			break;
		case KTNeighborUpRight:
			name = @"UPRIGHT";
			break;
		case KTNeighborRight:
			name = @"RIGHT";
			break;
		case KTNeighborDownRight:
			name = @"DOWNRIGHT";
			break;
		case KTNeighborDown:
			name = @"DOWN";
			break;
		case KTNeighborDownLeft:
			name = @"DOWNLEFT";
			break;
			
		default:
			name = @"INVALID INDEX!!!!";
			break;
	}
	
	return name;
}

-(void) dumpBlockMap
{
	NSMutableString* str = [NSMutableString stringWithCapacity:_blockMapCount];
	[str appendString:@"\n\nBlockMap:\n"];
	for (NSUInteger i = 0; i < _blockMapCount; i++)
	{
		if (i > 0 && i % ((NSUInteger)_blockMapSize.width) == 0)
		{
			[str appendString:@"\n"];
		}
		
		[str appendString:[self dumpCharacterForBlockMapIndex:i]];
		[str appendString:@" "];
	}
	
	NSLog(@"%@\n\n", str);
}

-(NSString*) dumpCharacterForBlockMapIndex:(NSUInteger)index
{
	NSString* blockChar = nil;
	
	if (_blockMap[index])
	{
		char contourChar = 'A';
		for (KTIntegerArray* contourIndices in _contours)
		{
			for (NSUInteger contourIndex = 0; contourIndex < contourIndices.count; contourIndex++)
			{
				if (contourIndices.integers[contourIndex] == index)
				{
					blockChar = [NSString stringWithFormat:@"%c", contourChar];
					break;
				}
			}
	
			contourChar++;
			if (blockChar)
			{
				break;
			}
		}
		
		if (blockChar == nil)
		{
			if ([self isOutOfBoundsTile:index])
			{
				blockChar = [NSString stringWithFormat:@"%c", 209];
			}
			else
			{
				blockChar = [NSString stringWithFormat:@"%c", 215];
			}
		}
	}
	else
	{
		blockChar = [NSString stringWithFormat:@"%c", 225];
	}
	
	return blockChar;
}

@end
