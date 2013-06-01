//
// KTPointArray.m
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 05.04.13.
//
//

#import "KTPointArray.h"

static const NSUInteger kDefaultNumberOfPointsToAllocate = 2;

@implementation KTPointArray

+(id) pointArrayWithCapacity:(NSUInteger)capacity
{
	return [[self alloc] initWithCapacity:capacity];
}

-(id) initWithCapacity:(NSUInteger)capacity
{
	self = [super init];
	if (self)
	{
		_count = 0;
		_numPointsAllocated = 0;
		[self allocateMemoryForNumberOfPoints:capacity];
	}

	return self;
}

-(id) init
{
	return [self initWithCapacity:kDefaultNumberOfPointsToAllocate];
}

+(id) pointArrayWithPoints:(CGPoint*)points count:(NSUInteger)count
{
	return [[self alloc] initWithPoints:points count:count];
}

-(id) initWithPoints:(CGPoint*)points count:(NSUInteger)count
{
	self = [super init];
	if (self)
	{
		[self addPoints:points count:count];
	}

	return self;
}

-(void) dealloc
{
	free(_points);
}

-(void) allocateMemoryForNumberOfPoints:(NSUInteger)additionalPoints
{
	NSUInteger requestedNumberOfPoints = _count + additionalPoints;
	if (requestedNumberOfPoints > _numPointsAllocated)
	{
		do
		{
			if (_numPointsAllocated == 0)
			{
				_numPointsAllocated = requestedNumberOfPoints;
			}
			else
			{
				_numPointsAllocated = (float)(_numPointsAllocated) * 1.5f;
			}
		}
		while (requestedNumberOfPoints > _numPointsAllocated);

		_points = realloc(_points, _numPointsAllocated * sizeof(CGPoint));
	}
} /* allocateMemoryForNumberOfPoints */

-(void) removeAllPoints
{
	_count = 0;
	_numPointsAllocated = 0;
	[self allocateMemoryForNumberOfPoints:kDefaultNumberOfPointsToAllocate];
}

-(void) removeLastPoint
{
	if (_count > 0)
	{
		_count--;
		[self allocateMemoryForNumberOfPoints:_count];
	}
}

-(void) removePointsStartingAtIndex:(NSUInteger)index
{
	if (index < _count)
	{
		_count = index;
		[self allocateMemoryForNumberOfPoints:_count];
	}
}

-(void) addPoint:(CGPoint)point
{
	[self allocateMemoryForNumberOfPoints:1];
	_points[_count++] = point;
}

-(void) addPoints:(CGPoint*)points count:(NSUInteger)count
{
	[self allocateMemoryForNumberOfPoints:count];

	for (NSUInteger i = 0; i < count; i++)
	{
		[self addPoint:points[i]];
	}
}

-(CGPoint) pointAtIndex:(NSUInteger)index
{
	NSAssert2(index < _count, @"index (%u) out of bounds! (num points: %u)", (unsigned int)index, (unsigned int)_count);
	return _points[index];
}

-(CGPoint) lastPoint
{
	if (_count > 0)
	{
		return _points[_count - 1];
	}
	return CGPointZero;
}

-(NSString*) description
{
	NSMutableString* str = [NSMutableString stringWithFormat:@"%@ - number of points: %lu\n", [super description], (unsigned long)_count];
	for (NSUInteger i = 0; i < _count; i++)
	{
		if (i > 0)
		{
			[str appendFormat:@","];
		}
		[str appendFormat:@"{%.0f,%.0f}", _points[i].x, _points[i].y];
	}
	return str;
}

@end
