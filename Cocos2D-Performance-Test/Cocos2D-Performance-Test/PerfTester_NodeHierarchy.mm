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
#import "HelloWorldLayer.h"

static int iterationsForAllNodeHierarchyTests = 0;

@implementation PerfTester (Misc)

-(void) testFirst_AddChildWithTag
{
	iterationsForAllNodeHierarchyTests = k10KIterationTestCount;
	
	CCNode* node = [HelloWorldLayer sharedLayer].testNode;
	
    BEGIN( iterationsForAllNodeHierarchyTests )
	[node addChild:[CCNode node] z:i tag:i];
    END()
}

-(void) testGetChildByTagWithNodes:(int)nodes;
{
	CCNode* node = [HelloWorldLayer sharedLayer].testNode;
	int tag = 1;
	
    BEGIN( k100KIterationTestCount )
	[node getChildByTag:tag++];
	if (tag > nodes) {
		tag = 1;
	}
    END()
}

-(void) testGetChildByTag_FewNodes
{
	int iters = 10;
	if (iters > iterationsForAllNodeHierarchyTests) 
	{
		iters = iterationsForAllNodeHierarchyTests;
	}
	[self testGetChildByTagWithNodes:iters];
}
-(void) testGetChildByTag_MediumNodes
{
	int iters = 100;
	if (iters > iterationsForAllNodeHierarchyTests) 
	{
		iters = iterationsForAllNodeHierarchyTests;
	}
	[self testGetChildByTagWithNodes:iters];
}
-(void) testGetChildByTag_ManyNodes
{
	int iters = 500;
	if (iters > iterationsForAllNodeHierarchyTests) 
	{
		iters = iterationsForAllNodeHierarchyTests;
	}
	[self testGetChildByTagWithNodes:iters];
}
-(void) testGetChildByTag_WayTooManyNodes
{
	int iters = 2500;
	if (iters > iterationsForAllNodeHierarchyTests) 
	{
		iters = iterationsForAllNodeHierarchyTests;
	}
	[self testGetChildByTagWithNodes:iters];
}

-(void) testLast_RemoveChildByTagWithCleanup
{
	CCNode* node = [HelloWorldLayer sharedLayer].testNode;
	
    BEGIN( iterationsForAllNodeHierarchyTests )
	[node removeChildByTag:i cleanup:YES];
    END()
}




-(void) addChildren:(int)num
{
	CCNode* node = [HelloWorldLayer sharedLayer].testNode;
	for (int i = 1; i <= num; i++) 
	{
		[node addChild:[CCNode node] z:i tag:i];
	}
}

-(void) removeAllChildren
{
	CCNode* node = [HelloWorldLayer sharedLayer].testNode;
	[node removeAllChildrenWithCleanup:YES];
}

-(void) testReorderChild_FewNodes
{
	int numChildren = 10;
	[self addChildren:numChildren];
	
	CCNode* node = [HelloWorldLayer sharedLayer].testNode;
	CCNode* reorderNode = [node getChildByTag:numChildren / 2];
	int randomZ = reorderNode.zOrder;
	srandom(123456789);
	
    BEGIN( k1MMIterationTestCount )
	randomZ = CCRANDOM_0_1() * numChildren;
	[node reorderChild:reorderNode z:randomZ];
    END()

	[self removeAllChildren];
}
-(void) testReorderChild_MediumNodes
{
	int numChildren = 100;
	[self addChildren:numChildren];
	
	CCNode* node = [HelloWorldLayer sharedLayer].testNode;
	CCNode* reorderNode = [node getChildByTag:numChildren / 2];
	int randomZ = reorderNode.zOrder;
	srandom(123456789);
	
    BEGIN( k1MMIterationTestCount )
	randomZ = CCRANDOM_0_1() * numChildren;
	[node reorderChild:reorderNode z:randomZ];
    END()
	
	[self removeAllChildren];
}
-(void) testReorderChild_ManyNodes
{
	int numChildren = 500;
	[self addChildren:numChildren];
	
	CCNode* node = [HelloWorldLayer sharedLayer].testNode;
	CCNode* reorderNode = [node getChildByTag:numChildren / 2];
	int randomZ = reorderNode.zOrder;
	srandom(123456789);
	
    BEGIN( k100KIterationTestCount )
	randomZ = CCRANDOM_0_1() * numChildren;
	[node reorderChild:reorderNode z:randomZ];
    END()
	
	[self removeAllChildren];
}
-(void) testReorderChild_WayTooManyNodes
{
	int numChildren = 2500;
	[self addChildren:numChildren];
	
	CCNode* node = [HelloWorldLayer sharedLayer].testNode;
	CCNode* reorderNode = [node getChildByTag:numChildren / 2];
	int randomZ = reorderNode.zOrder;
	srandom(123456789);
	
    BEGIN( k100KIterationTestCount )
	randomZ = CCRANDOM_0_1() * numChildren;
	[node reorderChild:reorderNode z:randomZ];
    END()
	
	[self removeAllChildren];
}

/*
- (void)testRemoveChildrenWithToDeleteArray
{
	int numChildren = 500;
	[self addChildren:numChildren];
	
	BEGIN ( k10MMIterationTestCount )
	int i = 0;
	CCArray* objectsToDelete = [CCArray array];
	CCNode* node;
	CCARRAY_FOREACH([self children], node)
	{
		if (i % 20 == 0) 
		{
			[objectsToDelete addObject:object];
		}
		i++;
	}
	
	[objectsToDelete removeAllObjects];
	END()
}
*/

@end
