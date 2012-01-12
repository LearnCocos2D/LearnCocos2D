/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKPixelMaskSprite.h"
#import "CCNodeExtensions.h"

int isPowerOfTwo (unsigned int x)
{
	return ((x != 0) && !(x & (x - 1)));
}

// caching the class for faster access
static Class PixelMaskSpriteClass = nil;

@implementation KKPixelMaskSprite

@synthesize pixelMask, pixelMaskWidth, pixelMaskHeight, pixelMaskSize;

-(id) initWithFile:(NSString *)filename alphaThreshold:(UInt8)alphaThreshold
{
	if ((self = [super initWithFile:filename]))
	{
		if (PixelMaskSpriteClass == nil) 
		{
			PixelMaskSpriteClass = [KKPixelMaskSprite class];
		}
		
		// this ensures that we're loading the -hd asset on Retina devices, if available
		NSString* fullpath = [CCFileUtils fullPathFromRelativePath:filename];
		UIImage* image = [[UIImage alloc] initWithContentsOfFile:fullpath];
		
		// get all the image information we need
		pixelMaskWidth = image.size.width;
		pixelMaskHeight = image.size.height;
		pixelMaskSize = pixelMaskWidth * pixelMaskHeight;

#if defined(__arm__) && !defined(__ARM_NEON__)
		NSAssert3(isPowerOfTwo(pixelMaskWidth) && isPowerOfTwo(pixelMaskHeight), 
				  @"Image '%@' size (%u, %u): pixel mask image must have power of two dimensions on 1st & 2nd gen devices.",
				  filename, pixelMaskWidth, pixelMaskHeight);
#endif
		
		// allocate and clear the pixelMask buffer
#if USE_BITARRAY
		pixelMask = BitArrayCreate(pixelMaskSize);
		BitArrayClearAll(pixelMask);
#else
		pixelMask = malloc(pixelMaskSize * sizeof(BOOL));
		memset(pixelMask, 0, pixelMaskSize * sizeof(BOOL));
#endif
		
		// get the pixel data (more correctly: texels) as 32-Bit unsigned integers
		CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
		const UInt32* imagePixels = (const UInt32*)CFDataGetBytePtr(imageData);
		UInt32 alphaValue = 0, x = 0, y = pixelMaskHeight - 1;
		UInt8 alpha = 0;

		for (NSUInteger i = 0; i < pixelMaskSize; i++)
		{
			// ensure that the pixelMask is created in the normal orientation (default would be upside down)
			NSUInteger index = y * pixelMaskWidth + x;
			x++;
			if (x == pixelMaskWidth)
			{
				x = 0;
				y--;
			}

			// mask out the colors so that only the alpha value remains (upper 8 bits)
			alphaValue = imagePixels[i] & 0xff000000;
			if (alphaValue > 0)
			{
				// get the 8-Bit alpha value, then compare it with the alpha threshold
				alpha = (UInt8)(alphaValue >> 24);
				if (alpha >= alphaThreshold)
				{
#if USE_BITARRAY
					BitArraySetBit(pixelMask, index);
#else
					pixelMask[index] = YES;
#endif
				}
			}
		}
		
		CFRelease(imageData);
		imageData = nil;
		[image release];
		image = nil;
	}
	return self;
}

+(id) spriteWithFile:(NSString *)filename
{
	return [[[self alloc] initWithFile:filename alphaThreshold:255] autorelease];
}

+(id) spriteWithFile:(NSString *)filename alphaThreshold:(UInt8)alphaThreshold
{
	return [[[self alloc] initWithFile:filename alphaThreshold:alphaThreshold] autorelease];
}

-(void) dealloc
{
	if (pixelMask)
	{
#if USE_BITARRAY
		BitArrayDestroy(pixelMask);
#else
		free(pixelMask);
#endif
		pixelMask = nil;
	}
	
	[super dealloc];
}

-(BOOL) pixelMaskBitAt:(CGPoint)point
{
	// round the point coordinates to the nearest integer
	int x = (int)(point.x + 0.5f);
	int y = (int)(point.y + 0.5f);

	if (x < 0 || y < 0 || x >= pixelMaskWidth || y >= pixelMaskHeight)
	{
		return NO;
	}

	NSUInteger index = y * pixelMaskWidth + x;
#if USE_BITARRAY
	return BitArrayTestBit(pixelMask, index);
#else
	return pixelMask[index];
#endif
}

-(BOOL) pixelMaskContainsPoint:(CGPoint)point
{
	// the point coordinates need to be relative to the node's space
	point = [self convertToNodeSpace:point];
	// upscale point to Retina pixels if necessary
	point = ccpMult(point, CC_CONTENT_SCALE_FACTOR());
	
	return [self pixelMaskBitAt:point];
}

-(CGRect) intersectRectInPixels:(CCNode*)node otherNode:(CCNode*)other
{
	CGRect myBBox = [node boundingBox];
	CGRect otherBBox = [other boundingBox];
	CGRect intersectRect = CGRectIntersection(myBBox, otherBBox);
	
	// transform the intersection rect to the sprite's space and convert points to pixels
	intersectRect.origin = [node convertToNodeSpace:intersectRect.origin];
	return CC_RECT_POINTS_TO_PIXELS(intersectRect);
}

-(BOOL) pixelMaskIntersectsPixelMaskSprite:(KKPixelMaskSprite*)other
{
	CGRect intersectSelf = [self intersectRectInPixels:self otherNode:other];
	CGRect intersectOther = [self intersectRectInPixels:other otherNode:self];
	
	NSUInteger originOffsetX = intersectOther.origin.x - intersectSelf.origin.x;
	NSUInteger originOffsetY = intersectOther.origin.y - intersectSelf.origin.y;
	NSUInteger otherPixelMaskWidth = other.pixelMaskWidth;
#if USE_BITARRAY
	bit_array_t* otherPixelMask = other.pixelMask;
#else
	BOOL* otherPixelMask = other.pixelMask;
#endif

	// check if any of the flags in the pixelMask are set within the intersection area
	NSUInteger maxX = intersectSelf.origin.x + intersectSelf.size.width;
	NSUInteger maxY = intersectSelf.origin.y + intersectSelf.size.height;
	for (NSUInteger y = intersectSelf.origin.y; y < maxY; y++)
	{
		for (NSUInteger x = intersectSelf.origin.x; x < maxX; x++)
		{
			NSUInteger index = y * pixelMaskWidth + x;
			NSAssert2(index < pixelMaskSize, @"pixelMask index out of bounds for x,y: %u, %u", x, y);
			
#if USE_BITARRAY
			if (BitArrayTestBit(pixelMask, index))
#else
			if (pixelMask[index])
#endif
			{
				// check if there's a pixel set at the same location in the pixelMask of the other sprite
				NSUInteger otherX = x + originOffsetX;
				NSUInteger otherY = y + originOffsetY;
				NSUInteger otherIndex = otherY * otherPixelMaskWidth + otherX;
				NSAssert2(otherIndex < other.pixelMaskSize,
						  @"other pixelMask index out of bounds for x,y: %u, %u", otherX, otherY);

#if USE_BITARRAY
				if (BitArrayTestBit(otherPixelMask, otherIndex))
#else
				if (otherPixelMask[otherIndex])
#endif
				{
					return YES;
				}
			}
		}
	}

	return NO;
}

-(BOOL) pixelMaskIntersectsRegularNode:(CCNode*)other
{
	CGRect intersectRect = [self intersectRectInPixels:self otherNode:other];
	
	// check if any of the flags in the pixelMask are set within the intersection area
	NSUInteger maxX = intersectRect.origin.x + intersectRect.size.width;
	NSUInteger maxY = intersectRect.origin.y + intersectRect.size.height;
	for (NSUInteger y = intersectRect.origin.y; y < maxY; y++)
	{
		for (NSUInteger x = intersectRect.origin.x; x < maxX; x++)
		{
			NSUInteger index = y * pixelMaskWidth + x;
			NSAssert2(index < pixelMaskSize, @"pixelMask index out of bounds for x,y: %u, %u", x, y);
#if USE_BITARRAY
			return BitArrayTestBit(pixelMask, index);
#else
			return pixelMask[index];
#endif
		}
	}
	
	return NO;
}

-(BOOL) pixelMaskIntersectsNode:(CCNode*)other
{
	if (rotation_ != 0.0f || other.rotation != 0.0f || self.scale != 1.0f || other.scale != 1.0f)
	{
		CCLOG(@"pixelMaskIntersectsNode: either or both nodes are rotated and/or scaled. This test only works with non-rotated, non-scaled nodes.");
		return NO;
	}
	
	// no point in testing further if bounding boxes don't intersect
	if ([self intersectsNode:other])
	{
		// if both are CCSpriteWithPixelMask nodes then we must perform a full pixel-to-pixel check
		if ([other isKindOfClass:PixelMaskSpriteClass])
		{
			KKPixelMaskSprite* maskSprite = (KKPixelMaskSprite*)other;
			return [self pixelMaskIntersectsPixelMaskSprite:maskSprite];
		}
		else
		{
			return [self pixelMaskIntersectsRegularNode:other];
		}
	}
	
	return NO;
}

@end
