//
//  HelloWorldLayer.h
//  Cocos2D-UpdateFilesFromWebServer
//
//  Created by Steffen Itterheim on 24.01.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "cocos2d.h"

enum 
{
	kTagForLocalWebSprites = 1,
	kTagForWorldWideWebSprites,
	kTagForAsyncModeLabel,
};

@interface HelloWorldLayer : CCLayer
{
	BOOL isCurrentlyMakingWebServerRequest;
}

+(CCScene *) scene;

@end

// helper class to carry info over to the background thread
@interface AsyncFileDownloadData : NSObject
{
	NSURL* url;
	NSString* localFile;
	int spriteTag;
}
@property (copy) NSURL* url;
@property (copy) NSString* localFile;
@property int spriteTag;
@end