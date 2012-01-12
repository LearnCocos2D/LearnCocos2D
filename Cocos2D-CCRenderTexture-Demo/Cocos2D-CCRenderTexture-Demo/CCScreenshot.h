//
//  CCScreenshot.h
//  Cocos2D-CCRenderTexture-Demo
//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import <Foundation/Foundation.h>

@interface CCScreenshot : NSObject

+(NSString*) screenshotPathForFile:(NSString*)file;
+(CCRenderTexture*) screenshotWithStartNode:(CCNode*)startNode filename:(NSString*)filename;

@end
