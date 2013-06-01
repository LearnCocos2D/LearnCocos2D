//
// KTPointArray.h
// KoboldTouch-Libraries
//
// Created by Steffen Itterheim on 05.04.13.
//
//

#import <Foundation/Foundation.h>

/** A simple and efficient array of CGPoint structs.

   The array is an allocated block of memory instead of boxing the CGPoint in NSValue objects. For most efficient use,
   set the array's capacity to hold the same number of points you're going to add. Otherwise buffer will grow as needed,
   allocating 50% more memory each time.

   Feature set is minimal, please request if you need something. For example there are deliberately no "insert point" or "remove point"
   methods because they're probably not going to be used (frequently). */
@interface KTPointArray : NSObject
{
	@private
	NSUInteger _numPointsAllocated;
}

/** Returns the number of points in the array. */
@property (nonatomic, readonly) NSUInteger count;
/** Returns the points array. Caution: Do not free() this buffer! Do not use index out of bounds! There are no safety checks here! */
@property (nonatomic, readonly) CGPoint* points;

/** Creates a points array, reserving capacity amount of memory for points. */
+(id) pointArrayWithCapacity:(NSUInteger)capacity;
/** Creates a points array by copying count points from the points buffer (array). You can delete (free) your points buffer after calling this method. */
+(id) pointArrayWithPoints:(CGPoint*)points count:(NSUInteger)count;

/** Adds the given number of points from an existing CGPoint array or memory buffer. */
-(void) addPoints:(CGPoint*)points count:(NSUInteger)count;
/** Adds a single point to the array. */
-(void) addPoint:(CGPoint)point;
/** Removes all points from the array. You can then start re-adding points. */
-(void) removeAllPoints;

/** Returns the point at the given index. If the index is out of bounds an exception is raised. */
-(CGPoint) pointAtIndex:(NSUInteger)index;

-(CGPoint) lastPoint;
-(void) removeLastPoint;
-(void) removePointsStartingAtIndex:(NSUInteger)index;

@end
