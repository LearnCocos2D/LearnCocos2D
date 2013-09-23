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


#import <mach/mach_time.h>

#import "PerfTester.h"

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
    
	NSAssert1([self respondsToSelector:sel], @"PerfTester class does not implement selector: %@", sel);
	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self performSelector: sel];
    [pool release];
    
    uint64_t duration = mEndTime - mStartTime;
    double floatDuration = duration * tbinfo.numer / tbinfo.denom;
    
    struct Result result = {
        mIterations,
        floatDuration / 1000000000.0,
        floatDuration / mIterations
    };
    return result;
}

- (void)test:(KKPerformanceTestType)testType
{
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

#if not defined __ARM_NEON__
	// perform fewer tests on older (armv6) devices
	NSLog(@"ARMV6 device detected, reducing number of test iterations.");
	k1000MMIterationTestCount	/= 10;
	k100MMIterationTestCount	/= 10;
	k10MMIterationTestCount		/= 10;
	k1MMIterationTestCount		/= 10;
	k100KIterationTestCount		/= 10;
	k10KIterationTestCount		/= 10;
	k1KIterationTestCount		/= 10;
	k100IterationTestCount		/= 10;
	k10IterationTestCount		/= 2;
#endif // not defined __ARM_NEON__
	
	
	Test testSels[100];
	
	// TODO: 
	/* 
	 add, subtract
	 property vs public instance variable
	 more on array performance
	 */
	
	switch (testType) 
	{
		case kkPerformanceTestArithmetic:
		{
			Test mytestSels[] = {
				{ @"Integer multiplication", @selector( testIntMultiplication ), },
				{ @"Float multiplication", @selector( testFloatMultiplication ), },
				{ @"Double multiplication", @selector( testDoubleMultiplication ), },
				{ @"Integer division", @selector( testIntDivision ), },
				{ @"Float division", @selector( testFloatDivision ), },
				{ @"Double division", @selector( testDoubleDivision ), },
				{ @"Float division with int conversion", @selector( testFloatConversionDivision ), },
				{ @"Double division with int conversion", @selector( testDoubleConversionDivision ), },
				{ @"Float square root", @selector( testFloatSquareRoot ), },
				{ @"Double square root", @selector( testDoubleSquareRoot ), },
				{ @"Accelerometer Highpass filter", @selector( testHighPassFilter ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case kkPerformanceTestArray:
		{
			Test mytestSels[] = {
				{ @"NSMutableArray insertObject: atIndex:0", @selector( testNSMutableArrayWithCapacityInsertObjectAtIndex0), },
				{ @"CCArray insertObject: atIndex:0", @selector( testCCArrayWithCapacityInsertObjectAtIndex0), },
				{ @"NSMutableArray insertObject: atIndex:random", @selector( testNSMutableArrayWithCapacityInsertObjectAtIndexHalfCount), },
				{ @"CCArray insertObject: atIndex:random", @selector( testCCArrayWithCapacityInsertObjectAtIndexHalfCount), },
				{ @"CCArray removeObjectAtIndex", @selector( testCCArrayRemoveObjectAtIndexAndAdd), },
				{ @"NSMutableArray removeObjectAtIndex", @selector( testNSMutableArrayRemoveObjectAtIndexAndAdd), },
				{ @"CCArray removeLastObject", @selector( testCCArrayRemoveLastObjectAndAdd), },
				{ @"NSMutableArray removeLastObject", @selector( testNSMutableArrayRemoveLastObjectAndAdd), },
				{ @"CCArray containsObject", @selector( testCCArrayContainsObject), },
				{ @"NSMutableArray containsObject", @selector( testNSMutableArrayContainsObject), },
				{ @"CCArray add/removeObjectsInArray", @selector( testCCArrayRemoveAndAddObjectsFromArray), },
				{ @"NSMutableArray add/removeObjectsInArray", @selector( testNSMutableArrayRemoveAndAddObjectsFromArray), },
				{ @"CCArray exchangeObjectAtIndex", @selector( testCCArrayExchangeObjectAtIndex), },
				{ @"NSMutableArray exchangeObjectAtIndex", @selector( testNSMutableArrayExchangeObjectAtIndex), },
				{ @"CCArray indexOfObject", @selector( testCCArrayIndexOfObject), },
				{ @"NSMutableArray indexOfObject", @selector( testNSMutableArrayIndexOfObject), },
				{ @"CCArray makeObjectsPerformSelector", @selector( testCCArrayMakeObjectsPerformSelector), },
				{ @"NSMutableArray makeObjectsPerformSelector", @selector( testNSMutableArrayMakeObjectsPerformSelector), },
				{ @"CCArray makeObjectsPerformSelector withObject", @selector( testCCArrayMakeObjectsPerformSelectorWithObject), },
				{ @"NSMutableArray makeObjectsPerformSelector withObject", @selector( testNSMutableArrayMakeObjectsPerformSelectorWithObject), },
				{ @"CCArray enumeration", @selector( testCCArrayEnumeration), },
				{ @"CCArray fast enumeration", @selector( testCCArrayFastEnumeration), },
				{ @"NSMutableArray enumeration", @selector( testNSMutableArrayEnumeration), },
				{ @"NSMutableArray fast enumeration", @selector( testNSMutableArrayFastEnumeration), },
				{ @"NSMutableArray addObject:", @selector( testNSMutableArrayAddObject), },
				{ @"CCArray addObject:", @selector( testCCArrayAddObject), },
				{ @"NSMutableArray withCapacity addObject:", @selector( testNSMutableArrayWithCapacityAddObject), },
				{ @"CCArray withCapacity addObject:", @selector( testCCArrayWithCapacityAddObject), },
				{ @"NSMutableArray objectAtIndex:", @selector( testObjCObjectAtIndex), },
				{ @"CCArray objectAtIndex:", @selector( testCCArrayObjectAtIndex), },
				{ @"CFArray GetValueAtIndex", @selector( testCFObjectAtIndex), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case kkPerformanceTestMemory:
		{
			Test mytestSels[] = {
				{ @"16 byte malloc/free", @selector( testSmallMallocFree ), },
				{ @"16MB malloc/free", @selector( testLargeMallocFree ), },
				{ @"16 byte memcpy", @selector( testSmallMemcpy ), },
				{ @"1MB memcpy", @selector( testLargeMemcpy ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case KKPerformanceTestObjectCreation:
		{
			Test mytestSels[] = {
				{ @"CCSprite GCD alloc/initWithFile/release", @selector( testCCSpriteWithFileCreationConcurrentlyWithGCD ), },
				{ @"CCSprite alloc/initWithFile/release", @selector( testCCSpriteWithFileCreation ), },
				
				{ @"CCTMXTiledMap small alloc/init/release", @selector( testCCTMXTiledMapSmallCreation ), },
				{ @"CCTMXTiledMap large alloc/init/release", @selector( testCCTMXTiledMapLargeCreation ), },
				//{ @"CCTMXTiledMap gigantic alloc/init/release", @selector( testCCTMXTiledMapGiganticCreation ), },
				{ @"CCParticleSystemQuad 25 particles alloc/init/release", @selector( testCCParticleSystemQuadSmallCreation ), },
				{ @"CCParticleSystemQuad 250 particles alloc/init/release", @selector( testCCParticleSystemQuadLargeCreation ), },
				{ @"NSAutoreleasePool alloc/init/release", @selector( testPoolCreation ), },
				{ @"NSObject alloc/init/release", @selector( testNSObjectCreation ), },
				{ @"CCNode alloc/init/release", @selector( testCCNodeCreation ), },
				{ @"CCLabelBMFont alloc/initWithString/release", @selector( testCCLabelBMFontWithStringCreation ), },
				{ @"CCLabelTTF alloc/initWithString/release", @selector( testCCLabelTTFWithStringCreation ), },
				{ @"CCMoveTo alloc/init/release", @selector( testCCMoveToCreation ), },
				{ @"CCSequence alloc/initOne/release", @selector( testCCSequenceCreation ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
			
		case KKPerformanceTestTextureLoading:
		{
			Test mytestSels[] = {
				/*
				{ @"PVRTC2_no-alpha.pvr", @selector( testLoadTexture_PVRTC2_no_alpha_pvr ), },
				{ @"PVRTC2_no-alpha.pvr.ccz", @selector( testLoadTexture_PVRTC2_no_alpha_pvrccz ), },
				{ @"PVRTC2_no-alpha.pvr.gz", @selector( testLoadTexture_PVRTC2_no_alpha_pvrgz ), },
				{ @"PVRTC4_no-alpha.pvr", @selector( testLoadTexture_PVRTC4_no_alpha_pvr ), },
				{ @"PVRTC4_no-alpha.pvr.ccz", @selector( testLoadTexture_PVRTC4_no_alpha_pvrccz ), },
				{ @"PVRTC4_no-alpha.pvr.gz", @selector( testLoadTexture_PVRTC4_no_alpha_pvrgz ), },
				*/

				{ @"PVRTC2.pvr", @selector( testLoadTexture_PVRTC2_pvr ), },
				{ @"PVRTC2.pvr.ccz", @selector( testLoadTexture_PVRTC2_pvrccz ), },
				{ @"PVRTC2.pvr.gz", @selector( testLoadTexture_PVRTC2_pvrgz ), },
				{ @"PVRTC4.pvr", @selector( testLoadTexture_PVRTC4_pvr ), },
				{ @"PVRTC4.pvr.ccz", @selector( testLoadTexture_PVRTC4_pvrccz ), },
				{ @"PVRTC4.pvr.gz", @selector( testLoadTexture_PVRTC4_pvrgz ), },

				{ @"RGB565.jpg", @selector( testLoadTexture_RGB565_jpg ), },
				{ @"RGB565.png", @selector( testLoadTexture_RGB565_png ), },
				{ @"RGB565.pvr", @selector( testLoadTexture_RGB565_pvr ), },
				{ @"RGB565.pvr.ccz", @selector( testLoadTexture_RGB565_pvrccz ), },
				{ @"RGB565.pvr.gz", @selector( testLoadTexture_RGB565_pvrgz ), },
				
				{ @"RGBA4444.jpg", @selector( testLoadTexture_RGBA4444_jpg ), },
				{ @"RGBA4444.png", @selector( testLoadTexture_RGBA4444_png ), },
				{ @"RGBA4444.pvr", @selector( testLoadTexture_RGBA4444_pvr ), },
				{ @"RGBA4444.pvr.ccz", @selector( testLoadTexture_RGBA4444_pvrccz ), },
				{ @"RGBA4444.pvr.gz", @selector( testLoadTexture_RGBA4444_pvrgz ), },

				{ @"RGBA5551.jpg", @selector( testLoadTexture_RGBA5551_jpg ), },
				{ @"RGBA5551.png", @selector( testLoadTexture_RGBA5551_png ), },
				{ @"RGBA5551.pvr", @selector( testLoadTexture_RGBA5551_pvr ), },
				{ @"RGBA5551.pvr.ccz", @selector( testLoadTexture_RGBA5551_pvrccz ), },
				{ @"RGBA5551.pvr.gz", @selector( testLoadTexture_RGBA5551_pvrgz ), },

				{ @"RGBA8888.jpg", @selector( testLoadTexture_RGBA8888_jpg ), },
				{ @"RGBA8888.png", @selector( testLoadTexture_RGBA8888_png ), },
				{ @"RGBA8888.pvr", @selector( testLoadTexture_RGBA8888_pvr ), },
				{ @"RGBA8888.pvr.ccz", @selector( testLoadTexture_RGBA8888_pvrccz ), },
				{ @"RGBA8888.pvr.gz", @selector( testLoadTexture_RGBA8888_pvrgz ), },

				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case KKPerformanceTestMessaging:
		{
			Test mytestSels[] = {
				{ @"ObjC setter w/o responds to selector", @selector( testSetterWithoutRespondsToSelectorCheck ), },
				{ @"ObjC setter with responds to selector", @selector( testSetterWithRespondsToSelectorCheck ), },
				{ @"ObjC setter with responds to selector (cached)", @selector( testSetterWithCachedSelectorRespondsToSelectorCheck ), },
				
				{ @"ObjC setter, not synchronized", @selector( testSetterNotSynchronized ), },
				{ @"ObjC setter, synchronized", @selector( testSetterSynchronized ), },

				{ @"ObjC class nonatomic property message send", @selector( testPrivateVariableReadWrite ), },
				{ @"ObjC class nonatomic property dot notation", @selector( testPrivateVariableReadWriteProperty ), },
				{ @"ObjC class atomic property message send", @selector( testPrivateVariableReadWriteAtomic ), },
				{ @"ObjC class atomic property dot notation", @selector( testPrivateVariableReadWriteAtomicProperty ), },
				{ @"ObjC class @public variable", @selector( testPublicVariableReadWrite ), },

				{ @"ObjC 2nd run setter, not synchronized", @selector( testSetterNotSynchronized ), },
				{ @"ObjC 2nd run setter, synchronized", @selector( testSetterSynchronized ), },

				{ @"Objective-C NSArray message send", @selector( testMessagingArray ), },
				{ @"Objective-C CCArray message send", @selector( testMessagingCCArray ), },
				{ @"Objective-C NSArray enumerateWithBlock msg send", @selector( testMessagingArrayUsingBlock ), },
				{ @"Objective-C NSArray enumerateWithBlock concurrent msg send", @selector( testMessagingArrayUsingBlockConcurrent ), },
				//{ @"Objective-C CCArray enumerateWithBlock msg send", @selector( testMessagingCCArrayUsingBlock ), },
				{ @"Objective-C NSArray makeObjectsPerformSelector", @selector( testMessagingArrayMakeObjectsPerformSelector ), },
				{ @"Objective-C CCArray makeObjectsPerformSelector", @selector( testMessagingCCArrayMakeObjectsPerformSelector ), },
				{ @"Objective-C message send", @selector( testMessaging ), },
				{ @"Objective-C performSelector", @selector( testMessagingPerformSelector ), },
				//{ @"Objective-C performSelector cached", @selector( testMessagingPerformSelectorCached ), },
				{ @"NSInvocation message send", @selector( testNSInvocation ), },
				{ @"IMP-cached message send", @selector( testIMPCachedMessaging ), },
				{ @"C++ virtual method call", @selector( testCPPVirtualCall ), },
				{ @"C++ cached virtual method call", @selector( testCPPCachedVirtualCall ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case KKPerformanceTestIO:
		{
			Test mytestSels[] = {
				{ @"Write 16-byte file", @selector( testWriteSmallFile ), },
				{ @"Write 16-byte file (atomic)", @selector( testWriteSmallFileAtomic ), },
				{ @"Write 16MB file", @selector( testWriteLargeFile ), },
				{ @"Write 16MB file (atomic)", @selector( testWriteLargeFileAtomic ), },
				{ @"Read 16-byte file", @selector( testReadSmallFile ), },
				{ @"Read 16MB file", @selector( testReadLargeFile ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case kkPerformanceTestMisc:
		{
			Test mytestSels[] = {
				{ @"pthread create/join", @selector( testSpawnThread ), },
				{ @"Zero-second delayed perform", @selector( testDelayedPerform ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case kkPerformanceTestNodeHierarchy:
		{
			Test mytestSels[] = {
				{ @"reorderChild w/ 10 Nodes", @selector( testReorderChild_FewNodes ), },
				{ @"reorderChild w/ 100 Nodes", @selector( testReorderChild_MediumNodes ), },
				{ @"reorderChild w/ 500 Nodes", @selector( testReorderChild_ManyNodes ), },
				{ @"reorderChild w/ 2,500 Nodes", @selector( testReorderChild_WayTooManyNodes ), },

				{ @"addChild with tag", @selector( testFirst_AddChildWithTag ), },
				{ @"getChildByTag w/ 10 Nodes", @selector( testGetChildByTag_FewNodes ), },
				{ @"getChildByTag w/ 100 Nodes", @selector( testGetChildByTag_MediumNodes ), },
				{ @"getChildByTag w/ 500 Nodes", @selector( testGetChildByTag_ManyNodes ), },
				{ @"getChildByTag w/ 2,500 Nodes", @selector( testGetChildByTag_WayTooManyNodes ), },
				{ @"removeChildByTag", @selector( testLast_RemoveChildByTagWithCleanup ), },

				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
		case kkPerformanceTestObjectCompare:
		{
			Test mytestSels[] = {
				{ @"NSObject hash", @selector( testObjectHash ), },
				{ @"NSString hash", @selector( testStringHash ), },
				{ @"NSObject isEqual", @selector( testPointerIsEqual ), },
				{ @"NSObject is not Equal", @selector( testPointerIsEqualFail ), },
				{ @"isMemberOfClass", @selector( testObjectIsMemberOfClass ), },
				{ @"isMemberOfClass, class cached", @selector( testObjectIsMemberOfClassOptimized ), },
				{ @"isKindOfClass", @selector( testObjectIsKindOfClass ), },
				{ @"isKindOfClass, class cached", @selector( testObjectIsKindOfClassOptimized ), },
				{ @"is not MemberOfClass", @selector( testObjectIsMemberOfClassFail ), },
				{ @"is not MemberOfClass, class cached", @selector( testObjectIsMemberOfClassOptimizedFail ), },
				{ @"is not KindOfClass", @selector( testObjectIsKindOfClassFail ), },
				{ @"is not KindOfClass, class cached", @selector( testObjectIsKindOfClassOptimizedFail ), },
				{ @"NSString isEqual", @selector( testStringCompareIsEqual ), },
				{ @"NSString is not Equal", @selector( testStringCompareIsEqualFail ), },
				{ @"NSString isEqualToString", @selector( testStringCompareIsEqualToString ), },
				{ @"NSString is not EqualToString", @selector( testStringCompareIsEqualToStringFail ), },
				{ nil, NULL }
			};
			memcpy(testSels, mytestSels, sizeof(mytestSels));
			break;
		}
	}

	NSMutableString *str = [NSMutableString string];
	switch (testType) 
	{
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
		NSLog( @"Testing %@ ...", testSels[i].name);
        struct Result result = [self _timeForSelector: testSels[i].sel];
        struct Result overheadResult = [self _timeForSelector: @selector( testNothing )];
		
        double total = result.totalDuration - overheadResult.totalDuration;
        double each = result.singleIterationNanosec - overheadResult.singleIterationNanosec;
        
        NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
							   testSels[i].name, @"name",
							   [NSNumber numberWithInt: result.iterations], @"iterations",
							   [NSNumber numberWithDouble: total], @"total",
							   [NSNumber numberWithDouble: each], @"each",
							   nil];
        [resultsArray addObject: entry];
        
		totalRunningTime += total;
		
		NSNumber* eachN = [NSNumber numberWithDouble:each];
		NSLog( @"completed %@ - Iter: %i, Time: %.1f s, Each: %@ ns", testSels[i].name, result.iterations, total, [nf stringFromNumber:eachN]);
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