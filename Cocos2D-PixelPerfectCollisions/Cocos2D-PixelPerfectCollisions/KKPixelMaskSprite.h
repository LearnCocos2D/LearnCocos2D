/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "bitarray.h"

// Bit array uses 1/8th of the memory of the regular BOOL array, but is about 30% slower
// set to 1 to use bit arrays instead of BOOL arrays
#define USE_BITARRAY 0

@interface KKPixelMaskSprite : CCSprite
{
	// Some useful improvements to this implementation would be:
	// cache pixelMasks for the same filename, to avoid wasting memory (much like CCTextureCache)
	// allow pixel mask to be created from a sprite frame
	// allow collisions between SD and HD assets (atm pixelMasks must be either both SD or both HD, collision tests return wrong results otherwise)
	// allow collisions if one or both sprites are rotated by exactly 90, 180 or 270 degrees
	
	// Possible optimizations:
	// reduce pixelMask size by combining the result of 2x2, 3x3, 4x4, etc pixel blocks into a single collision bit
	//	such a downscaled pixelMask would still be accurate enough for most use cases but require considerably less memory and is faster to iterate
	//	however picking a good algorithm that determines if a bit is set or not can be tricky
	// optimizing rectangle test: read multiple bits at once (byte or int), only compare individual bits if value > 0
	
	// Non-trivial improvement:
	// move the pixelMask array to CCTexture2D, to avoid loading the same image twice and take advantage of CCTextureCache
	// allow pixel perfect collisions if one or both nodes are rotated and/or scaled
	//		suggest using the render texture approach instead, as described here: http://www.cocos2d-iphone.org/forum/topic/18522
	// for purely "walking over landscape" type of games (think Tiny Wings but with an arbitrarily complex and rugged terrain),
	//	the pixelMask could be changed to contain only the pixel height (first pixel from top that's not alpha)
	//	That modification should be a separate class, labelled something like KKSpriteWithHeightMask.
	
#if USE_BITARRAY
	bit_array_t* pixelMask;
#else
	BOOL* pixelMask;
#endif
	NSUInteger pixelMaskWidth;
	NSUInteger pixelMaskHeight;
	NSUInteger pixelMaskSize;
	float pixelMaskResolutionFactor;
}

#if USE_BITARRAY
@property (nonatomic, readonly) bit_array_t* pixelMask;
#else
@property (nonatomic, readonly) BOOL* pixelMask;
#endif

@property (nonatomic, readonly) NSUInteger pixelMaskWidth;
@property (nonatomic, readonly) NSUInteger pixelMaskHeight;
@property (nonatomic, readonly) NSUInteger pixelMaskSize;

// alpha threshold determines how transparent a pixel can be to still be included in the pixel mask
// by default only fully opaque pixels (alpha threshold = 255) are considered
-(id) initWithFile:(NSString *)filename alphaThreshold:(UInt8)alphaThreshold;
+(id) spriteWithFile:(NSString *)filename;
+(id) spriteWithFile:(NSString *)filename alphaThreshold:(UInt8)alphaThreshold;

-(BOOL) pixelMaskContainsPoint:(CGPoint)point;
-(BOOL) pixelMaskIntersectsNode:(CCNode*)other;

@end
