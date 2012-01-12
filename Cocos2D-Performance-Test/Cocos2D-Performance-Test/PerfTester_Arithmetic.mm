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

@implementation PerfTester (Arithmetic)

- (void)testIntMultiplication
{
    int x;
 
    BEGIN( k100MMIterationTestCount )
	x = 13 * i;
    END()

	intRes = x;
}

- (void)testFloatMultiplication
{
    float x = doubleDiv;
    
    BEGIN( k100MMIterationTestCount )
	x = 1.3333f * x;
    END()
	
	floatRes = x;
}

- (void)testDoubleMultiplication
{
    double x = doubleDiv;
    
    BEGIN( k100MMIterationTestCount )
	x = 1.3333 * x;
    END()
	
	doubleRes = x;
}

- (void)testIntDivision
{
    int x;
    
    BEGIN( k100MMIterationTestCount )
	x = 1000000000 / i;
    END()
	intRes = x;
}

- (void)testFloatDivision
{
    float x = doubleDiv;
    
    BEGIN( k100MMIterationTestCount )
	x = 100000000.0f / x;
    END()
	
	floatRes = x;
}

- (void)testDoubleDivision
{
    double x = doubleDiv;
    
    BEGIN( k100MMIterationTestCount )
	x = 100000000.0 / x;
    END()
	
	doubleRes = x;
}

- (void)testFloatConversionDivision
{
    float x;
    
    BEGIN( k100MMIterationTestCount )
	x = 1000000000.0f / i;
    END()
	
	floatRes = x;
}

- (void)testDoubleConversionDivision
{
    double x;
    
    BEGIN( k100MMIterationTestCount )
	x = 1000000000.0 / i;
    END()
	
	doubleRes = x;
}

-(void) testFloatSquareRoot
{
	float x;
	
    BEGIN( k100MMIterationTestCount )
	x = sqrtf(1234.56789f);
    END()
	
	floatRes = x;
}

-(void) testDoubleSquareRoot
{
	double x;
	
    BEGIN( k100MMIterationTestCount )
	x = sqrt(1234.56789);
    END()

	doubleRes = x;
}

-(void) testHighPassFilter
{
	double accelX = 0.189437829;
	double accelY = 0.903849005;
	double accelZ = -0.398409233;
	double filterX = 0.0;
	double filterY = 0.0;
	double filterZ = 0.0;
	double filteringFactor = 0.2;
	
    BEGIN( k100MMIterationTestCount )
	filterX = accelX - ((accelX * filteringFactor) + (filterX * (1.0 - filteringFactor)));
	filterY = accelY - ((accelY * filteringFactor) + (filterY * (1.0 - filteringFactor)));
	filterZ = accelZ - ((accelZ * filteringFactor) + (filterZ * (1.0 - filteringFactor)));
    END()
	
	doubleRes = filterX + filterY + filterZ;
}

@end
