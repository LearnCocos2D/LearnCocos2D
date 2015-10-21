//
//  GameScene.m
//  EntityComponentSystemsTest
//
//  Created by Steffen Itterheim on 20/10/15.
//  Copyright (c) 2015 Steffen Itterheim. All rights reserved.
//

#import "GameScene.h"

#import "anax.hpp"
#import "entityx.h"
#import "Artemis.h"

#import <dispatch/dispatch.h>

extern "C" {
	extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));
}

#define PROFILE(name, iterations, codeBlock) { \
	uint64_t time = dispatch_benchmark(iterations, ^{ }); \
	NSLog(@"%@: %llu ns (%f ms)", name, time, time / 1000000.0); \
}

typedef NS_ENUM(NSInteger, BenchmarkType) {
	BenchmarkTypeBasic,
	BenchmarkTypeManySystemsFewComponents,
	BenchmarkTypeFewSystemsManyComponents,
	BenchmarkTypeCreateDestroyALot,
};

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    myLabel.text = @"Hello, World!";
    myLabel.fontSize = 45;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    [self addChild:myLabel];

	[self benchmarkEntityX:BenchmarkTypeBasic];
}

-(void)mouseDown:(NSEvent *)theEvent {
}

-(void)update:(CFTimeInterval)currentTime {
}

-(void) benchmarkEntityX:(BenchmarkType)benchmarkType {
	PROFILE(@"entity create/destroy", 1000 * 10000 * 10000, {
		entityx::EntityX ex;
		entityx::Entity entity = ex.entities.create();
		entity.destroy();
	});
}

@end
