//
//  CCScreenshot.m
//  Cocos2D-CCRenderTexture-Demo
//
//  Copyright (c) 2011 Steffen Itterheim.
//	Distributed under MIT License.
//

#import "CCScreenshot.h"

@implementation CCScreenshot

+(NSString*) screenshotPathForFile:(NSString *)file
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	NSString* screenshotPath = [documentsDirectory stringByAppendingPathComponent:file];
	return screenshotPath;
}

+(CCRenderTexture*) screenshotWithStartNode:(CCNode*)startNode filename:(NSString*)filename
{
	// Since taking a screenshot, saving it to disk and re-loading it as sprite may take some time,
	// it's a good idea to instruct CCDirector to reset the delta time for the next update.
	// Doing so will prevent the moving objects to make a significant jump in position or animation state.
	[CCDirector sharedDirector].nextDeltaTimeZero = YES;
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	CCRenderTexture* rtx = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
	
	// since this scene has no "see-through" areas, we don't need to clear the texture (a bit faster)
	[rtx begin];
	
	// just visit the scene node, this will send the visit message to all of the child nodes as well
	[startNode visit];
	
	[rtx end];
	
	// save as file as PNG
	// NOTE: using saveBuffer without format will write the file as JPG which are painfully slow to load on iOS!
	[rtx saveBuffer:[self screenshotPathForFile:filename] format:kCCImageFormatPNG];
	
	return rtx;
}

@end
