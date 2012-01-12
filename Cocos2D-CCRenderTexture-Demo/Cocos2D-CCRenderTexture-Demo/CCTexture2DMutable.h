//
//  CCMutableTexture.m
//	Created by Lam Hoang Pham
//		"Use this as freely as you wish" -- http://www.cocos2d-iphone.org/forum/topic/2449#post-16020
//  Improved by Manuel Martinez-Almeida.
//		https://github.com/manucorporat/AWTextureFilter
//

#import "CCTexture2D.h"
#import "ccTypes.h"

//#define CC_MUTABLE_TEXTURE_SAVE_ORIGINAL_DATA 1

@interface CCTexture2DMutable : CCTexture2D
{
#if CC_MUTABLE_TEXTURE_SAVE_ORIGINAL_DATA
	void *originalData_;
#endif
	void *data_;
	NSUInteger bytesPerPixel_;
	bool dirty_;
}
#if CC_MUTABLE_TEXTURE_SAVE_ORIGINAL_DATA
@property(nonatomic, readonly) void *originalTexData;
#endif
@property(nonatomic, readwrite) void *texData;

- (ccColor4B) pixelAt:(CGPoint) pt;

///
//	@param pt is a point to get a pixel (0,0) is top-left to (width,height) bottom-right
//	@param c is a ccColor4B which is a colour.
//	@returns if a pixel was set
//	Remember to call apply to actually update the texture canvas.
///
- (BOOL) setPixelAt:(CGPoint) pt rgba:(ccColor4B) c;

///
//	Fill with specified colour
///
- (void) fill:(ccColor4B) c;

///
//	@param textureToCopy is the texture image to copy over
//	@param offset also offset's the texture image
///
- (id) copyMutable:(BOOL)isMutable;

- (id) copy;

- (void) copy:(CCTexture2DMutable*)textureToCopy offset:(CGPoint) offset;

///
//	apply actually updates the texture with any new data we added.
///
- (void) apply;

@end

@compatibility_alias CCMutableTexture2D CCTexture2DMutable;
