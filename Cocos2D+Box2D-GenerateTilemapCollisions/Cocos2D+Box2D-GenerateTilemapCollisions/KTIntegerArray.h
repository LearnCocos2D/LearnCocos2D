//
//  KTIntegerArray.h
//  Cocos2D+Box2D-GenerateTilemapCollisions
//
//  Created by Steffen Itterheim on 29.05.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KTIntegerArray : NSObject
{
@private
	NSUInteger _numIntegersAllocated;
}

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSUInteger* integers;

+(id) integerArrayWithCapacity:(NSUInteger)capacity;

-(void) addInteger:(NSUInteger)integer;
-(void) removeAllIntegers;
-(NSUInteger) integerAtIndex:(NSUInteger)index;
-(NSUInteger) lastInteger;

@end
