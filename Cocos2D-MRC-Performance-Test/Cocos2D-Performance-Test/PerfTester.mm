//
//  PerfTester
//
//  Copyright 2007-2008 Mike Ash
//					http://mikeash.com/pyblog/performance-comparisons-of-common-operations.html
//					http://mikeash.com/pyblog/performance-comparisons-of-common-operations-leopard-edition.html
//					http://mikeash.com/pyblog/performance-comparisons-of-common-operations-iphone-edition.html
//	Copyright 2010 Manomio / Stuart Carnie  (iOS port)
//					http://aussiebloke.blogspot.com/2010/01/micro-benchmarking-2nd-3rd-gen-iphones.html
//	Copyright 2011 Steffen Itterheim (Improvements, Cocos2D & ARC Tests)
//					http://www.learn-cocos2d.com/blog
//


#import <mach/mach_time.h>

#import "PerfTester.h"
#import "MRCTests.h"

@implementation PerfTester

@synthesize quickTest, webView;

-(void) setQuickTest:(BOOL)quick
{
	quickTest = quick;
	NSLog(@"Quick Testing is %@.", quickTest ? @"ON" : @"OFF");
}

-(id) init
{
	if ((self = [super init]))
	{
		NSLog(@"Starting tests ...");

		// clean previous log
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		logFile = [documentsDirectory stringByAppendingPathComponent:@"log.html"];
		if ([[NSFileManager defaultManager] fileExistsAtPath:logFile]) 
		{
			[[NSFileManager defaultManager] removeItemAtPath:logFile error:nil];
		}
	}
	return self;
}

struct Result
{
    int iterations;
    double totalDuration;
    double singleIterationNanosec;
};

- (struct Result)_timeForSelector: (SEL)sel
{
    struct mach_timebase_info tbinfo;
    mach_timebase_info( &tbinfo );
    
    mStartTime = mEndTime = 0;
    
	NSAssert1([self respondsToSelector:sel], @"PerfTester class does not implement selector: %@", NSStringFromSelector(sel));
	
    @autoreleasepool {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self performSelector: sel];
#pragma clang diagnostic pop
    }
    
    uint64_t duration = mEndTime - mStartTime;
    double floatDuration = duration * tbinfo.numer / tbinfo.denom;
    
    struct Result result = {
        mIterations,
        floatDuration / 1000000000.0,
        floatDuration / mIterations
    };
    return result;
}

-(void) setupARCvsMRCTests
{
	if (mrcTest == nil)
	{
		mrcTest = [MRCTests mrcTests];
	}
}

- (void)test:(KKPerformanceTestType)testType
{
	[self setupARCvsMRCTests];
	
	if (quickTest)
	{
		k1000MMIterationTestCount	= 100000000;
		k100MMIterationTestCount	= 10000000;
		k10MMIterationTestCount		= 100000;
		k1MMIterationTestCount		= 10000;
		k100KIterationTestCount		= 1000;
		k10KIterationTestCount		= 100;
		k1KIterationTestCount		= 20;
		k100IterationTestCount		= 8;
		k10IterationTestCount		= 4;
	}
	else
	{
		k1000MMIterationTestCount	= 1000000000;
		k100MMIterationTestCount	= 100000000;
		k10MMIterationTestCount		= 10000000;
		k1MMIterationTestCount		= 1000000;
		k100KIterationTestCount		= 100000;
		k10KIterationTestCount		= 10000;
		k1KIterationTestCount		= 1000;
		k100IterationTestCount		= 100;
		k10IterationTestCount		= 10;
	}

	Test testSels[100];
	
	// TODO:
	/* 
	 add, subtract
	 property vs public instance variable
	 more on array performance
	 */
	
	switch (testType) 
	{
		case kkPerformanceTestARCvsMRC_Messaging:
		{
			Test mytestSels[] = {
				{ "MRC: Message Send to Object\0", @selector( testMessageSendObject ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case kkPerformanceTestARCvsMRC_AllocInit:
		{
			Test mytestSels[] = {
				{ "MRC: Create Alloc/Init Object\0", @selector( testInternalCreateAllocInitObject ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case kkPerformanceTestARCvsMRC_Autorelease:
		{
			Test mytestSels[] = {
				{ "MRC: Create Autorelease Object\0", @selector( testInternalCreateAutoreleaseObject ), },
				{ "MRC: Create & Return Autorelease Object\0", @selector( testCreateAndReturnAutoreleaseObject ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}

		
		
		case kkPerformanceTestArithmetic:
		{
			Test mytestSels[] = {
				{ "Integer multiplication\0", @selector( testIntMultiplication ), },
				{ "Float multiplication\0", @selector( testFloatMultiplication ), },
				{ "Double multiplication\0", @selector( testDoubleMultiplication ), },
				{ "Integer division\0", @selector( testIntDivision ), },
				{ "Float division\0", @selector( testFloatDivision ), },
				{ "Double division\0", @selector( testDoubleDivision ), },
				{ "Float division with int conversion\0", @selector( testFloatConversionDivision ), },
				{ "Double division with int conversion\0", @selector( testDoubleConversionDivision ), },
				{ "Float square root\0", @selector( testFloatSquareRoot ), },
				{ "Double square root\0", @selector( testDoubleSquareRoot ), },
				{ "Accelerometer Highpass filter\0", @selector( testHighPassFilter ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case kkPerformanceTestArray:
		{
			Test mytestSels[] = {
				{ "NSMutableArray insertObject: atIndex:0\0", @selector( testNSMutableArrayWithCapacityInsertObjectAtIndex0), },
				{ "CCArray insertObject: atIndex:0\0", @selector( testCCArrayWithCapacityInsertObjectAtIndex0), },
				{ "NSMutableArray insertObject: atIndex:random\0", @selector( testNSMutableArrayWithCapacityInsertObjectAtIndexHalfCount), },
				{ "CCArray insertObject: atIndex:random\0", @selector( testCCArrayWithCapacityInsertObjectAtIndexHalfCount), },
				{ "CCArray removeObjectAtIndex\0", @selector( testCCArrayRemoveObjectAtIndexAndAdd), },
				{ "NSMutableArray removeObjectAtIndex\0", @selector( testNSMutableArrayRemoveObjectAtIndexAndAdd), },
				{ "CCArray removeLastObject\0", @selector( testCCArrayRemoveLastObjectAndAdd), },
				{ "NSMutableArray removeLastObject\0", @selector( testNSMutableArrayRemoveLastObjectAndAdd), },
				{ "CCArray containsObject\0", @selector( testCCArrayContainsObject), },
				{ "NSMutableArray containsObject\0", @selector( testNSMutableArrayContainsObject), },
				{ "CCArray add/removeObjectsInArray\0", @selector( testCCArrayRemoveAndAddObjectsFromArray), },
				{ "NSMutableArray add/removeObjectsInArray\0", @selector( testNSMutableArrayRemoveAndAddObjectsFromArray), },
				{ "CCArray exchangeObjectAtIndex\0", @selector( testCCArrayExchangeObjectAtIndex), },
				{ "NSMutableArray exchangeObjectAtIndex\0", @selector( testNSMutableArrayExchangeObjectAtIndex), },
				{ "CCArray indexOfObject\0", @selector( testCCArrayIndexOfObject), },
				{ "NSMutableArray indexOfObject\0", @selector( testNSMutableArrayIndexOfObject), },
				{ "CCArray makeObjectsPerformSelector\0", @selector( testCCArrayMakeObjectsPerformSelector), },
				{ "NSMutableArray makeObjectsPerformSelector\0", @selector( testNSMutableArrayMakeObjectsPerformSelector), },
				{ "CCArray makeObjectsPerformSelector withObject\0", @selector( testCCArrayMakeObjectsPerformSelectorWithObject), },
				{ "NSMutableArray makeObjectsPerformSelector withObject\0", @selector( testNSMutableArrayMakeObjectsPerformSelectorWithObject), },
				{ "CCArray enumeration\0", @selector( testCCArrayEnumeration), },
				{ "CCArray fast enumeration\0", @selector( testCCArrayFastEnumeration), },
				{ "NSMutableArray enumeration\0", @selector( testNSMutableArrayEnumeration), },
				{ "NSMutableArray fast enumeration\0", @selector( testNSMutableArrayFastEnumeration), },
				{ "NSMutableArray addObject:\0", @selector( testNSMutableArrayAddObject), },
				{ "CCArray addObject:\0", @selector( testCCArrayAddObject), },
				{ "NSMutableArray withCapacity addObject:\0", @selector( testNSMutableArrayWithCapacityAddObject), },
				{ "CCArray withCapacity addObject:\0", @selector( testCCArrayWithCapacityAddObject), },
				{ "NSMutableArray objectAtIndex:\0", @selector( testObjCObjectAtIndex), },
				{ "CCArray objectAtIndex:\0", @selector( testCCArrayObjectAtIndex), },
				{ "CFArray GetValueAtIndex\0", @selector( testCFObjectAtIndex), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case kkPerformanceTestMemory:
		{
			Test mytestSels[] = {
				{ "16 byte malloc/free\0", @selector( testSmallMallocFree ), },
				{ "16MB malloc/free\0", @selector( testLargeMallocFree ), },
				{ "16 byte memcpy\0", @selector( testSmallMemcpy ), },
				{ "1MB memcpy\0", @selector( testLargeMemcpy ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case KKPerformanceTestObjectCreation:
		{
			Test mytestSels[] = {
				{ "CCSprite GCD alloc/initWithFile/release\0", @selector( testCCSpriteWithFileCreationConcurrentlyWithGCD ), },
				{ "CCSprite alloc/initWithFile/release\0", @selector( testCCSpriteWithFileCreation ), },
				
				{ "CCTMXTiledMap small alloc/init/release\0", @selector( testCCTMXTiledMapSmallCreation ), },
				{ "CCTMXTiledMap large alloc/init/release\0", @selector( testCCTMXTiledMapLargeCreation ), },
				//{ "CCTMXTiledMap gigantic alloc/init/release\0", @selector( testCCTMXTiledMapGiganticCreation ), },
				{ "CCParticleSystemQuad 25 particles alloc/init/release\0", @selector( testCCParticleSystemQuadSmallCreation ), },
				{ "CCParticleSystemQuad 250 particles alloc/init/release\0", @selector( testCCParticleSystemQuadLargeCreation ), },
				{ "NSAutoreleasePool alloc/init/release\0", @selector( testPoolCreation ), },
				{ "NSObject alloc/init/release\0", @selector( testNSObjectCreation ), },
				{ "CCNode alloc/init/release\0", @selector( testCCNodeCreation ), },
				{ "CCLabelBMFont alloc/initWithString/release\0", @selector( testCCLabelBMFontWithStringCreation ), },
				{ "CCLabelTTF alloc/initWithString/release\0", @selector( testCCLabelTTFWithStringCreation ), },
				{ "CCMoveTo alloc/init/release\0", @selector( testCCMoveToCreation ), },
				{ "CCSequence alloc/initOne/release\0", @selector( testCCSequenceCreation ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
			
		case KKPerformanceTestTextureLoading:
		{
			Test mytestSels[] = {
				/*
				{ "PVRTC2_no-alpha.pvr\0", @selector( testLoadTexture_PVRTC2_no_alpha_pvr ), },
				{ "PVRTC2_no-alpha.pvr.ccz\0", @selector( testLoadTexture_PVRTC2_no_alpha_pvrccz ), },
				{ "PVRTC2_no-alpha.pvr.gz\0", @selector( testLoadTexture_PVRTC2_no_alpha_pvrgz ), },
				{ "PVRTC4_no-alpha.pvr\0", @selector( testLoadTexture_PVRTC4_no_alpha_pvr ), },
				{ "PVRTC4_no-alpha.pvr.ccz\0", @selector( testLoadTexture_PVRTC4_no_alpha_pvrccz ), },
				{ "PVRTC4_no-alpha.pvr.gz\0", @selector( testLoadTexture_PVRTC4_no_alpha_pvrgz ), },
				*/

				{ "PVRTC2.pvr\0", @selector( testLoadTexture_PVRTC2_pvr ), },
				{ "PVRTC2.pvr.ccz\0", @selector( testLoadTexture_PVRTC2_pvrccz ), },
				{ "PVRTC2.pvr.gz\0", @selector( testLoadTexture_PVRTC2_pvrgz ), },
				{ "PVRTC4.pvr\0", @selector( testLoadTexture_PVRTC4_pvr ), },
				{ "PVRTC4.pvr.ccz\0", @selector( testLoadTexture_PVRTC4_pvrccz ), },
				{ "PVRTC4.pvr.gz\0", @selector( testLoadTexture_PVRTC4_pvrgz ), },

				{ "RGB565.jpg\0", @selector( testLoadTexture_RGB565_jpg ), },
				{ "RGB565.png\0", @selector( testLoadTexture_RGB565_png ), },
				{ "RGB565.pvr\0", @selector( testLoadTexture_RGB565_pvr ), },
				{ "RGB565.pvr.ccz\0", @selector( testLoadTexture_RGB565_pvrccz ), },
				{ "RGB565.pvr.gz\0", @selector( testLoadTexture_RGB565_pvrgz ), },
				
				{ "RGBA4444.jpg\0", @selector( testLoadTexture_RGBA4444_jpg ), },
				{ "RGBA4444.png\0", @selector( testLoadTexture_RGBA4444_png ), },
				{ "RGBA4444.pvr\0", @selector( testLoadTexture_RGBA4444_pvr ), },
				{ "RGBA4444.pvr.ccz\0", @selector( testLoadTexture_RGBA4444_pvrccz ), },
				{ "RGBA4444.pvr.gz\0", @selector( testLoadTexture_RGBA4444_pvrgz ), },

				{ "RGBA5551.jpg\0", @selector( testLoadTexture_RGBA5551_jpg ), },
				{ "RGBA5551.png\0", @selector( testLoadTexture_RGBA5551_png ), },
				{ "RGBA5551.pvr\0", @selector( testLoadTexture_RGBA5551_pvr ), },
				{ "RGBA5551.pvr.ccz\0", @selector( testLoadTexture_RGBA5551_pvrccz ), },
				{ "RGBA5551.pvr.gz\0", @selector( testLoadTexture_RGBA5551_pvrgz ), },

				{ "RGBA8888.jpg\0", @selector( testLoadTexture_RGBA8888_jpg ), },
				{ "RGBA8888.png\0", @selector( testLoadTexture_RGBA8888_png ), },
				{ "RGBA8888.pvr\0", @selector( testLoadTexture_RGBA8888_pvr ), },
				{ "RGBA8888.pvr.ccz\0", @selector( testLoadTexture_RGBA8888_pvrccz ), },
				{ "RGBA8888.pvr.gz\0", @selector( testLoadTexture_RGBA8888_pvrgz ), },

				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case KKPerformanceTestMessaging:
		{
			Test mytestSels[] = {
				{ "ObjC class nonatomic property message send\0", @selector( testPrivateVariableReadWrite ), },
				{ "ObjC class nonatomic property dot notation\0", @selector( testPrivateVariableReadWriteProperty ), },
				{ "ObjC class atomic property message send\0", @selector( testPrivateVariableReadWriteAtomic ), },
				{ "ObjC class atomic property dot notation\0", @selector( testPrivateVariableReadWriteAtomicProperty ), },
				{ "ObjC class @public variable\0", @selector( testPublicVariableReadWrite ), },
				
				{ "Objective-C NSArray message send\0", @selector( testMessagingArray ), },
				{ "Objective-C CCArray message send\0", @selector( testMessagingCCArray ), },
				{ "Objective-C NSArray enumerateWithBlock msg send\0", @selector( testMessagingArrayUsingBlock ), },
				{ "Objective-C NSArray enumerateWithBlock concurrent msg send\0", @selector( testMessagingArrayUsingBlockConcurrent ), },
				//{ "Objective-C CCArray enumerateWithBlock msg send\0", @selector( testMessagingCCArrayUsingBlock ), },
				{ "Objective-C NSArray makeObjectsPerformSelector\0", @selector( testMessagingArrayMakeObjectsPerformSelector ), },
				{ "Objective-C CCArray makeObjectsPerformSelector\0", @selector( testMessagingCCArrayMakeObjectsPerformSelector ), },
				{ "Objective-C message send\0", @selector( testMessaging ), },
				{ "Objective-C performSelector\0", @selector( testMessagingPerformSelector ), },
				//{ "Objective-C performSelector cached\0", @selector( testMessagingPerformSelectorCached ), },
				{ "NSInvocation message send\0", @selector( testNSInvocation ), },
				{ "IMP-cached message send\0", @selector( testIMPCachedMessaging ), },
				{ "C++ virtual method call\0", @selector( testCPPVirtualCall ), },
				{ "C++ cached virtual method call\0", @selector( testCPPCachedVirtualCall ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case KKPerformanceTestIO:
		{
			Test mytestSels[] = {
				{ "Write 16-byte file\0", @selector( testWriteSmallFile ), },
				{ "Write 16-byte file (atomic)\0", @selector( testWriteSmallFileAtomic ), },
				{ "Write 16MB file\0", @selector( testWriteLargeFile ), },
				{ "Write 16MB file (atomic)\0", @selector( testWriteLargeFileAtomic ), },
				{ "Read 16-byte file\0", @selector( testReadSmallFile ), },
				{ "Read 16MB file\0", @selector( testReadLargeFile ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case kkPerformanceTestMisc:
		{
			Test mytestSels[] = {
				{ "pthread create/join\0", @selector( testSpawnThread ), },
				{ "Zero-second delayed perform\0", @selector( testDelayedPerform ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case kkPerformanceTestNodeHierarchy:
		{
			Test mytestSels[] = {
				{ "reorderChild w/ 10 Nodes\0", @selector( testReorderChild_FewNodes ), },
				{ "reorderChild w/ 100 Nodes\0", @selector( testReorderChild_MediumNodes ), },
				{ "reorderChild w/ 500 Nodes\0", @selector( testReorderChild_ManyNodes ), },
				{ "reorderChild w/ 2,500 Nodes\0", @selector( testReorderChild_WayTooManyNodes ), },

				{ "addChild with tag\0", @selector( testFirst_AddChildWithTag ), },
				{ "getChildByTag w/ 10 Nodes\0", @selector( testGetChildByTag_FewNodes ), },
				{ "getChildByTag w/ 100 Nodes\0", @selector( testGetChildByTag_MediumNodes ), },
				{ "getChildByTag w/ 500 Nodes\0", @selector( testGetChildByTag_ManyNodes ), },
				{ "getChildByTag w/ 2,500 Nodes\0", @selector( testGetChildByTag_WayTooManyNodes ), },
				{ "removeChildByTag\0", @selector( testLast_RemoveChildByTagWithCleanup ), },

				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case kkPerformanceTestObjectCompare:
		{
			Test mytestSels[] = {
				{ "NSObject hash\0", @selector( testObjectHash ), },
				{ "NSString hash\0", @selector( testStringHash ), },
				{ "NSObject isEqual\0", @selector( testPointerIsEqual ), },
				{ "NSObject is not Equal\0", @selector( testPointerIsEqualFail ), },
				{ "isMemberOfClass\0", @selector( testObjectIsMemberOfClass ), },
				{ "isMemberOfClass, class cached\0", @selector( testObjectIsMemberOfClassOptimized ), },
				{ "isKindOfClass\0", @selector( testObjectIsKindOfClass ), },
				{ "isKindOfClass, class cached\0", @selector( testObjectIsKindOfClassOptimized ), },
				{ "is not MemberOfClass\0", @selector( testObjectIsMemberOfClassFail ), },
				{ "is not MemberOfClass, class cached\0", @selector( testObjectIsMemberOfClassOptimizedFail ), },
				{ "is not KindOfClass\0", @selector( testObjectIsKindOfClassFail ), },
				{ "is not KindOfClass, class cached\0", @selector( testObjectIsKindOfClassOptimizedFail ), },
				{ "NSString isEqual\0", @selector( testStringCompareIsEqual ), },
				{ "NSString is not Equal\0", @selector( testStringCompareIsEqualFail ), },
				{ "NSString isEqualToString\0", @selector( testStringCompareIsEqualToString ), },
				{ "NSString is not EqualToString\0", @selector( testStringCompareIsEqualToStringFail ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
	}

	NSMutableString *str = [NSMutableString string];
	switch (testType) 
	{
		case kkPerformanceTestARCvsMRC_Messaging:
		case kkPerformanceTestARCvsMRC_AllocInit:
		case kkPerformanceTestARCvsMRC_Autorelease:
			[str appendString:@"<h4>ARC vs MRC Tests</h4>Comparing the same test with both automatic reference counting (ARC) enabled and disabled (MRC)."];
			break;
		case kkPerformanceTestArithmetic:
			[str appendString:@"<h4>Arithmetic Tests</h4>Simple calculations done frequently in an app, using various data types."];
			break;
		case kkPerformanceTestArray:
			[str appendString:@"<h4>Array Tests</h4>Testing Cocos2D's CCArray performance against regular NSMutableArray."];
			break;
		case kkPerformanceTestMemory:
			[str appendString:@"<h4>Memory Tests</h4>Allocating and releasing memory."];
			break;
		case KKPerformanceTestObjectCreation:
			[str appendString:@"<h4>Object Creation</h4>These tests tell you how long it takes to allocate memory, \
			 initialize the object, and deallocate it. The longer this takes for an object, the higher the chance that \
			 doing this during gameplay will negatively affect performance. Note that <strong>these tests do not give any indication \
			 whatsoever of the runtime/rendering performance</strong> of these objects."];
			break;
		case KKPerformanceTestTextureLoading:
			[str appendString:@"<h4>Loading Textures</h4>Time it takes to load and unload the same 1024x1024 texture using a variety of different image file formats, compression and color bit depths."];
			break;
		case KKPerformanceTestMessaging:
			[str appendString:@"<h4>Messaging / Function Calls</h4>Low-level overhead for calling C++ functions respectively sending Objective-C messages in various ways."];
			break;
		case KKPerformanceTestIO:
			[str appendString:@"<h4>File IO</h4>"];
			break;
		case kkPerformanceTestMisc:
			[str appendString:@"<h4>Miscellaneous Tests</h4>"];
			break;
		case kkPerformanceTestNodeHierarchy:
			[str appendString:@"<h4>Node Hierarchy (children)</h4>The performance of functions that act on the node hierarchy (children list) depends heavily on the number of children."];
			break;
		case kkPerformanceTestObjectCompare:
			[str appendString:@"<h4>Object Comparison</h4>Compare objects with various methods, and testing if it makes any difference if the test fails (mismatch) or succeeds (match)."];
			break;
	}

	doubleDiv = 42.3;
	
    mIterations = 100000000;
	if (quickTest == NO) {
		mIterations *= 10;
	}
	
    [self _timeForSelector: @selector( testNothing )];
	NSLog(@"completed measuring @selector timing ...");

	NSNumberFormatter* nf = [[NSNumberFormatter alloc] init];
	[nf setMaximumFractionDigits:0];
	[nf setNumberStyle:NSNumberFormatterDecimalStyle];

    NSMutableArray *resultsArray = [NSMutableArray array];
    int i;
    for( i = 0; testSels[i].name; i++ )
    {
		NSString* name = [NSString stringWithCString:testSels[i].name encoding:NSUTF8StringEncoding];
		NSLog( @"Testing %@ ...", name);
        struct Result result = [self _timeForSelector: testSels[i].sel];
        struct Result overheadResult = [self _timeForSelector: @selector( testNothing )];
		
        double total = result.totalDuration - overheadResult.totalDuration;
        double each = result.singleIterationNanosec - overheadResult.singleIterationNanosec;
        
        NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
							   name, @"name",
							   [NSNumber numberWithInt: result.iterations], @"iterations",
							   [NSNumber numberWithDouble: total], @"total",
							   [NSNumber numberWithDouble: each], @"each",
							   nil];
        [resultsArray addObject: entry];
        
		totalRunningTime += total;
		
		NSNumber* eachN = [NSNumber numberWithDouble:each];
		NSLog( @"completed %@ - Iter: %i, Time: %.1f s, Each: %@ ns", name, result.iterations, total, [nf stringFromNumber:eachN]);
    }
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey: @"each" ascending: YES];
    [resultsArray sortUsingDescriptors: [NSArray arrayWithObject: descriptor]];
	[descriptor release];
	
	//[str appendString: @"<p><table border=\"1\"><tr><td>Name</td><td>Iterations</td><td>Total Time (sec)</td><td>Per Exec Time (ns)</td></tr>"];
    [str appendString: @"<p><table border=\"1\"><tr><td>Name</td><td>Each (ns)</td></tr>"];

    NSEnumerator *enumerator = [resultsArray objectEnumerator];
    id obj;
    while( (obj = [enumerator nextObject]) )
    {
        NSString *name = [obj objectForKey: @"name"];
        int iterations = [[obj objectForKey: @"iterations"] intValue];
        double total = [[obj objectForKey: @"total"] doubleValue];
        NSNumber* each = [NSNumber numberWithDouble:[[obj objectForKey: @"each"] doubleValue]];
        
		//[str appendFormat: @"<tr><td>%@</td><td align=\"right\">%d</td><td align=\"right\">%.1f</td><td align=\"right\">%.1f</td></tr>", name, iterations, total, each];
        [str appendFormat: @"<tr><td>%@</td><td align=\"right\">%@</td></tr>", name, [nf stringFromNumber:each]];
    }
    [str appendString: @"</table></p>\n"];
    
    //[(NSFileHandle *)[NSFileHandle fileHandleWithStandardOutput] writeData: [str dataUsingEncoding: NSUTF8StringEncoding]];

	NSString* logFileStr = [NSString stringWithContentsOfFile:logFile encoding:NSUTF8StringEncoding error:nil];
	if (logFileStr == nil) 
	{
#if TARGET_IPHONE_SIMULATOR
		logFileStr = @"<font color=#ff0000><strong>IMPORTANT: THE RESULTS FROM THIS TEST RUN ARE COMPLETELY DEVOID OF ANY MEANING!<br/> \
		The results below should not be compared, discussed, rated, evaluated, thought about or used in any other way or form!</strong></font><br><br> \
		<a href=\"http://stackoverflow.com/questions/4825750/why-this-code-runs-slow-on-device-but-fast-on-simulator-in-iphone\">Why?</a><br/> \
		Because you ran the tests on the <strong>iOS Simulator</strong>. That's like test-driving a Porsche through a cornfield. \
		It's possible, but the results don't give any indication whatsoever to real-world, end-user performance.<br><br><strong> \
		<font color=#ff0000>To get meaningful results you MUST run the tests on an iOS Device!</font></strong>";
#else
		logFileStr = @"A nanosecond (ns) is one billionth of a second (0.000 000 001 second). \
					  One nanosecond is to one second as one second is to 31.7 years. \
					  One Gigahertz (GHz) equals 1,000,000,000 Hz. One cycle of a 1 GHz CPU takes 1 nanosecond.";
#endif
	}
	logFileStr = [NSString stringWithFormat:@"%@ %@", logFileStr, str];
	[logFileStr writeToFile:logFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
	
	[nf release];
}

- (void)beginTest
{
    mStartTime = mach_absolute_time();
}

- (void)endTestWithIterations: (int)iters
{
    mEndTime = mach_absolute_time();
    mIterations = iters;
}

-(void) showResultsInView:(UIView*)view
{
	webView = [[UIWebView alloc] initWithFrame:[view frame]];
	webView.exclusiveTouch = NO;
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:logFile]]];	
	[view addSubview:webView];
}

-(void) printResultsToStandardOutput
{
	NSLog(@"Total Running Time: %.1f minutes", totalRunningTime / 60.0);
	printf("\n\n\n");
	NSString* logFileStr = [NSString stringWithContentsOfFile:logFile encoding:NSASCIIStringEncoding error:nil];
    [(NSFileHandle *)[NSFileHandle fileHandleWithStandardOutput] writeData:[logFileStr dataUsingEncoding:NSUTF8StringEncoding]];
	printf("\n\n\n");
}


@end