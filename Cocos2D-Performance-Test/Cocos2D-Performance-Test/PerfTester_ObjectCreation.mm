//
//  PerfTester
//
//  Copyright 2007-2008 Mike Ash
//					http://mikeash.com/pyblog/performance-comparisons-of-common-operations.html
//					http://mikeash.com/pyblog/performance-comparisons-of-common-operations-leopard-edition.html
//					http://mikeash.com/pyblog/performance-comparisons-of-common-operations-iphone-edition.html
//	Copyright 2010 Manomio / Stuart Carnie  (iOS port)
//					http://aussiebloke.blogspot.com/2010/01/micro-benchmarking-2nd-3rd-gen-iphones.html
//	Copyright 2011 Steffen Itterheim (Improvements, Cocos2D Tests)
//					http://www.learn-cocos2d.com/blog
//


#import "PerfTester.h"

@implementation PerfTester (ObjectCreation)

- (void)testPoolCreation
{
    BEGIN( k10MMIterationTestCount )
	[[[NSAutoreleasePool alloc] init] release];
    END()
}

- (void)testNSObjectCreation
{
    BEGIN( k10MMIterationTestCount )
	[[[NSObject alloc] init] release];
    END()
}

- (void)testCCNodeCreation
{
    BEGIN( k10MMIterationTestCount )
	[[[CCNode alloc] init] release];
    END()
}

- (void)testCCSpriteWithFileCreation
{
	// cache the texture
	[[CCTextureCache sharedTextureCache] addImage:@"Icon.png"];
	
    BEGIN( k1MMIterationTestCount )
	[[[CCSprite alloc] initWithFile:@"Icon.png"] release];
    END()
}

-(void) testCCLabelBMFontWithStringCreation
{
    BEGIN( k100KIterationTestCount )
	[[[CCLabelBMFont alloc] initWithString:@"Hello World!" fntFile:@"Arial14.fnt"] release];
    END()
}

- (void)testCCLabelTTFWithStringCreation
{
    BEGIN( k100KIterationTestCount )
	[[[CCLabelTTF alloc] initWithString:@"Hello World!" fontName:@"Arial" fontSize:14] release];
    END()
}

- (void)testCCMoveToCreation
{
    BEGIN( k100KIterationTestCount )
	[[[CCMoveTo alloc] initWithDuration:3 position:CGPointMake(123, 234)] release];
    END()
}

- (void)testCCSequenceCreation
{
	id move1 = [CCMoveTo actionWithDuration:3 position:CGPointMake(100, 100)];
	id move2 = [CCMoveTo actionWithDuration:3 position:CGPointMake(100, 100)];
	
    BEGIN( k100KIterationTestCount )
	[[[CCSequence alloc] initOne:move1 two:move2] release];
    END()
}

- (void)testCCParticleSystemQuadSmallCreation
{
    BEGIN( k1KIterationTestCount )
	[[[CCParticleSystemQuad alloc] initWithTotalParticles:25] release];
    END()
}

- (void)testCCParticleSystemQuadLargeCreation
{
    BEGIN( k100IterationTestCount )
	[[[CCParticleSystemQuad alloc] initWithTotalParticles:250] release];
    END()
}

- (void)testCCTMXTiledMapSmallCreation
{
	// cache the texture
	[[CCTextureCache sharedTextureCache] addImage:@"dg_grounds32.png"];

    BEGIN( k100IterationTestCount )
	[[[CCTMXTiledMap alloc] initWithTMXFile:@"tilemap-small.tmx"] release];
    END()
}
- (void)testCCTMXTiledMapLargeCreation
{
	// cache the texture
	[[CCTextureCache sharedTextureCache] addImage:@"dg_grounds32.png"];
	
    BEGIN( k10IterationTestCount )
	[[[CCTMXTiledMap alloc] initWithTMXFile:@"tilemap-large.tmx"] release];
    END()
}
- (void)testCCTMXTiledMapGiganticCreation
{
	// cache the texture
	[[CCTextureCache sharedTextureCache] addImage:@"dg_grounds32.png"];
	
    BEGIN( k10IterationTestCount )
	[[[CCTMXTiledMap alloc] initWithTMXFile:@"tilemap-gigantic.tmx"] release];
    END()
}


@end
