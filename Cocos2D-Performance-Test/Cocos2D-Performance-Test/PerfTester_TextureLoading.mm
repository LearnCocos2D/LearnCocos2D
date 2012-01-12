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

-(void) testLoadTexture_PVRTC2_pvr
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k1KIterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_PVRTC2.pvr"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_PVRTC2_pvrccz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k10KIterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_PVRTC2.pvr.czz"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_PVRTC2_pvrgz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k1KIterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_PVRTC2.pvr.gz"];
	[cache removeTexture:tex];
    END()
}

-(void) testLoadTexture_PVRTC4_pvr
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k1KIterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_PVRTC4.pvr"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_PVRTC4_pvrccz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k10KIterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_PVRTC4.pvr.czz"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_PVRTC4_pvrgz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k1KIterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_PVRTC4.pvr.gz"];
	[cache removeTexture:tex];
    END()
}


-(void) testLoadTexture_PVRTC2_no_alpha_pvr
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k1KIterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_PVRTC2_no-alpha.pvr"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_PVRTC2_no_alpha_pvrccz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k10KIterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_PVRTC2_no-alpha.pvr.czz"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_PVRTC2_no_alpha_pvrgz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k1KIterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_PVRTC2_no-alpha.pvr.gz"];
	[cache removeTexture:tex];
    END()
}

-(void) testLoadTexture_PVRTC4_no_alpha_pvr
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k1KIterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_PVRTC4_no-alpha.pvr"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_PVRTC4_no_alpha_pvrccz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k10KIterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_PVRTC4_no-alpha.pvr.czz"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_PVRTC4_no_alpha_pvrgz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k1KIterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_PVRTC4_no-alpha.pvr.gz"];
	[cache removeTexture:tex];
    END()
}



-(void) testLoadTexture_RGB565_jpg
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k10IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGB565.jpg"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGB565_png
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGB565.png"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGB565_pvr
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGB565.pvr"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGB565_pvrccz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGB565.pvr.ccz"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGB565_pvrgz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGB565.pvr.gz"];
	[cache removeTexture:tex];
    END()
}



-(void) testLoadTexture_RGBA4444_jpg
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k10IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA4444.jpg"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGBA4444_png
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA4444.png"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGBA4444_pvr
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA4444.pvr"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGBA4444_pvrccz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA4444.pvr.ccz"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGBA4444_pvrgz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA4444.pvr.gz"];
	[cache removeTexture:tex];
    END()
}




-(void) testLoadTexture_RGBA5551_jpg
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k10IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA5551.jpg"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGBA5551_png
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA5551.png"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGBA5551_pvr
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA5551.pvr"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGBA5551_pvrccz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA5551.pvr.ccz"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGBA5551_pvrgz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA5551.pvr.gz"];
	[cache removeTexture:tex];
    END()
}




-(void) testLoadTexture_RGBA8888_jpg
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k10IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA8888.jpg"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGBA8888_png
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA8888.png"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGBA8888_pvr
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA8888.pvr"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGBA8888_pvrccz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA8888.pvr.ccz"];
	[cache removeTexture:tex];
    END()
}
-(void) testLoadTexture_RGBA8888_pvrgz
{
	CCTextureCache* cache = [CCTextureCache sharedTextureCache];
	
    BEGIN( k100IterationTestCount )
	CCTexture2D* tex = [cache addImage:@"textureatlas_RGBA8888.pvr.gz"];
	[cache removeTexture:tex];
    END()
}

@end
