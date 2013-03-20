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

@implementation PerfTester (IO)

- (void)_testWriteFileSize: (int)size atomic: (BOOL)atomic count: (int)count
{
    NSData *data = [[NSFileHandle fileHandleForReadingAtPath: @"/dev/random"] readDataOfLength: size];
    BEGIN( count )
	[data writeToFile: @"/tmp/testrand" atomically: atomic];
    END()
    [[NSFileManager defaultManager] removeItemAtPath: @"/tmp/testrand" error:nil];
}

- (void)testWriteSmallFile
{
    [self _testWriteFileSize: 16 atomic: NO count: 10000];
}

- (void)testWriteSmallFileAtomic
{
    [self _testWriteFileSize: 16 atomic: YES count: 10000];
}

- (void)testWriteLargeFile
{
    [self _testWriteFileSize: 1 << 24 atomic: NO count: 30];
}

- (void)testWriteLargeFileAtomic
{
    [self _testWriteFileSize: 1 << 24 atomic: YES count: 30];
}

- (void)_testReadFileSize: (int)size count: (int)count
{
    NSData *data = [[NSFileHandle fileHandleForReadingAtPath: @"/dev/random"] readDataOfLength: size];
    [data writeToFile: @"/tmp/testrand" atomically: NO];
    
    BEGIN( count )
	id obj = [[NSData alloc] initWithContentsOfFile: @"/tmp/testrand"];
	[obj release];
    END()
    
    [[NSFileManager defaultManager] removeItemAtPath: @"/tmp/testrand" error:nil];
}

- (void)testReadSmallFile
{
    [self _testReadFileSize: 16 count: 100000];
}

- (void)testReadLargeFile
{
    [self _testReadFileSize: 1 << 24 count: 100];
}

@end
