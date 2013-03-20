//
//  MRCTests.h
//  Cocos2D-ARC-Performance-Test
//
//  Created by Steffen Itterheim on 20.03.13.
//
//

#import <Foundation/Foundation.h>

@interface MRCTests : NSObject

+(id) mrcTests;
-(void) createAutoreleaseObject;
-(void) createAllocInitObject;
-(void) messageThatDoesNothing;
-(CCNode*) createAndReturnAutoreleaseObject;;

@end
