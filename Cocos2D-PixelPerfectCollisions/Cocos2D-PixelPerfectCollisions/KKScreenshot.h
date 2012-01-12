/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface KKScreenshot : NSObject

+(NSString*) screenshotPathForFile:(NSString*)file;
+(CCRenderTexture*) screenshotWithStartNode:(CCNode*)startNode filename:(NSString*)filename;

@end
