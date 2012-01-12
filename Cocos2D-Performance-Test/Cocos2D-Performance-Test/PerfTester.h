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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "cocos2d.h"

typedef enum
{
	kkPerformanceTestArithmetic,
	kkPerformanceTestArray,
	kkPerformanceTestMemory,
	KKPerformanceTestObjectCreation,
	KKPerformanceTestTextureLoading,
	KKPerformanceTestMessaging,
	KKPerformanceTestIO,
	kkPerformanceTestMisc,
	kkPerformanceTestNodeHierarchy,
	kkPerformanceTestObjectCompare,
} KKPerformanceTestType;

typedef struct { NSString *name; SEL sel; } Test;

#define BEGIN( count ) \
int iters = count; \
int i; \
[self beginTest]; \
for( i = 1; i <= iters; i++ ) {

#define END() \
} \
[self endTestWithIterations: iters];

@interface PerfTester : NSObject
{
    uint64_t	mStartTime, mEndTime;
    int			mIterations;
	double totalRunningTime;
	
	BOOL quickTest;
	NSString *logFile;

	UIWebView* webView;

	int k1000MMIterationTestCount;
	int k100MMIterationTestCount;
	int k10MMIterationTestCount;
	int k1MMIterationTestCount;
	int k100KIterationTestCount;
	int k10KIterationTestCount;
	int k1KIterationTestCount;
	int k100IterationTestCount;
	int k10IterationTestCount;
	
	int intRes;
	float floatRes;
	double doubleRes;
	double doubleDiv;
}

@property (nonatomic) BOOL quickTest;
@property (nonatomic, readonly) UIWebView* webView;

// for internal use only
- (void)beginTest;
- (void)endTestWithIterations: (int)iters;

// external API
-(void) test:(KKPerformanceTestType)type;
-(void) printResultsToStandardOutput;
-(void) showResultsInView:(UIView*)view;

@end

