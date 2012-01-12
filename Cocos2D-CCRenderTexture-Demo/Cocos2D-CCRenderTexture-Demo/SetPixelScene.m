//
//  SetPixelScene.m
//  Cocos2D-CCRenderTexture-Demo
//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "SetPixelScene.h"

@implementation SetPixelScene


-(id) init
{
	if ((self = [super init])) 
	{
		glClearColor(1, 1, 1, 1);
		
		CGSize texSize = CGSizeMake(128, 128);
		
		// initialize a mutable texture with a block of memory set to white (0xffffffff)
		int bytes = texSize.width * texSize.height * 4;
		textureData = malloc(bytes);
		memset(textureData, INT32_MAX, bytes);
		CCMutableTexture2D* tex = [[CCMutableTexture2D alloc] initWithData:textureData 
															   pixelFormat:kCCTexture2DPixelFormat_RGBA8888
																pixelsWide:texSize.width
																pixelsHigh:texSize.height
															   contentSize:texSize];
		[tex autorelease];
		
		// disable texture filtering (no smoothing, clear and crisp pixels)
		[tex setAliasTexParameters];
		
		sprite = [CCSprite spriteWithTexture:tex];
		
		// zoom the sprite so we can get a better view on the pixels
		sprite.scale = 6;
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		sprite.position = CGPointMake(size.width / 2, size.height / 2);
		[self addChild:sprite];
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"CCTexture2DMutable setPixel demo (zoomed in)" fontName:@"Arial" fontSize:20];
		label.position = CGPointMake(240, 15);
		label.color = ccBLACK;
		[self addChild:label];
		
		[self scheduleUpdate];
		[self schedule:@selector(changeColorCycleMode) interval:4];
	}
	return self;
}

-(void) dealloc
{
	sprite.texture = nil;
	[super dealloc];
}

-(void) changeColorCycleMode
{
	colorCycleMode++;
	if (colorCycleMode == ColorCycle_End) 
	{
		colorCycleMode = 0;
	}
}

-(void) update:(ccTime)delta
{
	CGRect rect = [sprite boundingBox];
	CCMutableTexture2D* tex = (CCMutableTexture2D*)sprite.texture;
	
	for (int i = 0; i < 2500; i++)
	{
		CGPoint randomPos = CGPointMake(rect.size.width * CCRANDOM_0_1(), rect.size.height * CCRANDOM_0_1());
		ccColor4B color = ccc4(colorCycleMode == ColorCycleRed ? 255 : 50,
							   colorCycleMode == ColorCycleGreen ? 255 : 50, 
							   colorCycleMode == ColorCycleBlue ? 255 : 50, 
							   CCRANDOM_0_1() * 200 + 55);
		[tex setPixelAt:randomPos rgba:color];
	}
	
	[tex apply];
}

@end
