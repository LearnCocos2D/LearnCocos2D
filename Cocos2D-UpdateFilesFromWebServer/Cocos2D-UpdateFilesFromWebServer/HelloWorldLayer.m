//
//  HelloWorldLayer.m
//  Cocos2D-UpdateFilesFromWebServer
//
//  Created by Steffen Itterheim on 24.01.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "HelloWorldLayer.h"

// Replace this with the (local) IP address of your Mac
// Refer to the System Preferences -> Sharing -> Web Sharing panel to obtain that address.
NSString* const kLocalWebServerAddress = @"192.168.0.8";
// This is the file on your Mac's web server we like to (re)load
NSString* const kLocalWebServerFile = @"webserverfile.png";


// Since this also works with the world wide web, why not try that as well?
// It's one of the Ottawa traffic cams: http://www.camscape.com/view/2198
NSString* const kWorldWideWebServerAddress = @"207.251.86.248";
// tip: change the number in the filename to something else to see a different webcam
NSString* const kWorldWideWebServerFile = @"cctv47.jpg";
// other interesting cams: 43, 47, 68, 70

// Should the above image not work for you, try my StackExchange flair image instead
//NSString* const kWorldWideWebServerAddress = @"stackexchange.com/users/flair";
//NSString* const kWorldWideWebServerFile = @"69373.png";

// tell the code to prefer asynchronous operations where possible
static BOOL useAsynchronousOperations = YES;


@implementation AsyncFileDownloadData
@synthesize url, localFile, spriteTag;
-(void) dealloc
{
	//CCLOG(@"dealloc %@", self);
	[url release];
	[localFile release];
	[super dealloc];
}
@end 



@interface HelloWorldLayer (PrivateMethods)
-(void) updateTexturesWithAsyncData:(AsyncFileDownloadData*)afd;
@end

@implementation HelloWorldLayer

-(void) logError:(NSError*)error
{
	if (error) 
	{
		CCLOG(@"%@: %@", error, [error localizedDescription]);
	}
}

-(NSString*) documentsDirectory
{
	NSString* documentsDirectory = nil;
	NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([pathArray count] > 0)
	{
		documentsDirectory = [pathArray objectAtIndex:0];
	}
	return documentsDirectory;
}

-(BOOL) isNewerFileOnServer:(NSString*)server filename:(NSString*)filename spriteTag:(int)spriteTag
{
	BOOL isNewer = YES;

	NSString* localFile = [[self documentsDirectory] stringByAppendingPathComponent:filename];
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	if ([fileManager fileExistsAtPath:localFile])
	{
		// create a HTTP request to get the file information from the web server
		NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@", server, filename]];
		NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
		[request setHTTPMethod:@"HEAD"];

		NSHTTPURLResponse* response;
		NSError* error = nil;

		[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		[self logError:error];
		
		// get the last modified info from the HTTP header
		NSString* httpLastModified = nil;
		if ([response respondsToSelector:@selector(allHeaderFields)])
		{
			httpLastModified = [[response allHeaderFields] objectForKey:@"Last-Modified"];
		}  
		
		// setup a date formatter to query the server file's modified date
		NSDateFormatter* df = [[[NSDateFormatter alloc] init] autorelease];
		df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
		df.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
		df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
		
		// get the file attributes to retrieve the local file's modified date
		NSDictionary* fileAttributes = [fileManager attributesOfItemAtPath:localFile error:&error];
		[self logError:error];
		
		// test if the server file's date is later than the local file's date
		NSDate* serverFileDate = [df dateFromString:httpLastModified];
		NSDate* localFileDate = [fileAttributes fileModificationDate];
		isNewer = ([localFileDate laterDate:serverFileDate] == serverFileDate);
	}

	return isNewer;
}

-(void) downloadFileFromServerInBackground:(AsyncFileDownloadData*)afd
{
	NSError* error = nil;
	NSData* data = [NSData dataWithContentsOfURL:afd.url options:NSDataReadingMappedIfSafe error:&error];
	[self logError:error];
	
	[data writeToFile:afd.localFile options:NSDataWritingAtomic error:&error];
	[self logError:error];
	
	// wait until done in this case means that the background thread waits for completion of the task
	// manipulating or creating sprites must be done on the main thread
	[self performSelectorOnMainThread:@selector(updateTexturesWithAsyncData:) withObject:afd waitUntilDone:NO];
}

-(NSString*) downloadFileFromServer:(NSString*)server filename:(NSString*)filename spriteTag:(int)spriteTag
{
	NSString* localFile = [[self documentsDirectory] stringByAppendingPathComponent:filename];
	
	// only download the file from web server if it is newer
	//if ([self isNewerFileOnServer:server filename:filename])
	{
		NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@", server, filename]];
		
		//CCLOG(@"Trying to download newer file from URL: %@", url);

		if (useAsynchronousOperations)
		{
			AsyncFileDownloadData* afd = [[[AsyncFileDownloadData alloc] init] autorelease];
			afd.url = url;
			afd.localFile = localFile;
			afd.spriteTag = spriteTag;
			
			// note: performSelectorInBackground retains afd until task is complete
			[self performSelectorInBackground:@selector(downloadFileFromServerInBackground:) withObject:afd];
		}
		else
		{
			NSError* error = nil;
			NSData* data = [NSData dataWithContentsOfURL:url 
												 options:NSDataReadingMappedIfSafe
												   error:&error];
			[self logError:error];
			
			[data writeToFile:localFile
					  options:NSDataWritingAtomic 
						error:&error];
			[self logError:error];
		}
	}

	return localFile;
}

-(void) updateChildrenWithTag:(int)spriteTag texture:(CCTexture2D*)newTexture
{
	CCSprite* sprite;
	CCARRAY_FOREACH(self.children, sprite)
	{
		if (sprite.tag == spriteTag)
		{
			sprite.texture = newTexture;
		}
	}
}

-(void) asyncTextureLoadDidFinishForLocalWebSprites:(CCTexture2D*)texture
{
	[self updateChildrenWithTag:kTagForLocalWebSprites texture:texture];
}
-(void) asyncTextureLoadDidFinishForWorldWideWebSprites:(CCTexture2D*)texture
{
	[self updateChildrenWithTag:kTagForWorldWideWebSprites texture:texture];
}

-(void) updateTexturesFromFile:(NSString*)file forSpritesWithTag:(int)spriteTag
{
	CCSprite* spriteWithTag = (CCSprite*)[self getChildByTag:spriteTag];
	if (spriteWithTag)
	{
		// clear the currently cached texture and force it to be reloaded
		CCTextureCache* texCache = [CCTextureCache sharedTextureCache];
		[texCache removeTexture:spriteWithTag.texture];
		
		if (useAsynchronousOperations)
		{
			// since operation is asynchronous and you can't provide userdata to the selector, 
			// you must use unique selectors for each spriteTag			
			if (spriteTag == kTagForLocalWebSprites)
			{
				[texCache addImageAsync:file 
								 target:self
							   selector:@selector(asyncTextureLoadDidFinishForLocalWebSprites:)];
			}
			else if (spriteTag == kTagForWorldWideWebSprites)
			{
				[texCache addImageAsync:file
								 target:self
							   selector:@selector(asyncTextureLoadDidFinishForWorldWideWebSprites:)];
			}
			else
			{
				NSAssert1(nil, @"unsupported spriteTag %i for asynchronous texture load", spriteTag);
			}
		}
		else
		{
			CCTexture2D* newTexture = [texCache addImage:file];
			[self updateChildrenWithTag:spriteTag texture:newTexture];
		}
	}
}

// this just calls updateTexturesFromFile after returning from the background download selector
-(void) updateTexturesWithAsyncData:(AsyncFileDownloadData*)afd
{
	[self updateTexturesFromFile:afd.localFile forSpritesWithTag:afd.spriteTag];
}

-(void) updateWebSprites:(ccTime)delta
{
	// update the sprites whenever the web server's image file has changed
	//if ([self isNewerFileOnServer:kLocalWebServerAddress filename:kLocalWebServerFile spriteTag:kTagForLocalWebSprites])
	{
		NSString* localFile = [self downloadFileFromServer:kLocalWebServerAddress 
												  filename:kLocalWebServerFile 
												 spriteTag:kTagForLocalWebSprites];
		
		if (useAsynchronousOperations == NO)
		{
			[self updateTexturesFromFile:localFile forSpritesWithTag:kTagForLocalWebSprites];
		}
	}
	
	//if ([self isNewerFileOnServer:kWorldWideWebServerAddress filename:kWorldWideWebServerFile spriteTag:kTagForLocalWebSprites])
	{
		NSString* localFile = [self downloadFileFromServer:kWorldWideWebServerAddress 
												  filename:kWorldWideWebServerFile
												 spriteTag:kTagForWorldWideWebSprites];

		if (useAsynchronousOperations == NO)
		{
			[self updateTexturesFromFile:localFile forSpritesWithTag:kTagForWorldWideWebSprites];
		}
	}
}

-(void) updateAsyncModeLabelString
{
	CCLabelTTF* label = (CCLabelTTF*)[self getChildByTag:kTagForAsyncModeLabel];
	if (useAsynchronousOperations)
	{
		label.string = @"Asynchronous Mode";
	}
	else
	{
		label.string = @"Synchronous Mode";
	}
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// switch mode
	useAsynchronousOperations = !useAsynchronousOperations;
	[self updateAsyncModeLabelString];
}

-(id) init
{
	if ((self = [super init]))
	{
		// during init we can't use async mode!
		BOOL rememberAsyncSetting = useAsynchronousOperations;
		useAsynchronousOperations = NO;
		
		// clear color is being reset when reloading textures
		glClearColor(0.9f, 0.75f, 0.45f, 1.0f);

		{
			NSString* localFile = [self downloadFileFromServer:kLocalWebServerAddress 
													  filename:kLocalWebServerFile
													 spriteTag:kTagForLocalWebSprites];
			
			CCSprite* webSprite = [CCSprite spriteWithFile:localFile];
			webSprite.position = CGPointMake(240, 160);
			webSprite.tag = kTagForLocalWebSprites;
			webSprite.opacity = 80;
			webSprite.color = ccGREEN;
			[self addChild:webSprite];
			
			// there's nothing scarier than a frighteningly subtle animation :)
			float duration = 50.0f;
			id skew1 = [CCSkewTo actionWithDuration:duration skewX:-10 skewY:-10];
			id ease1 = [CCEaseSineInOut actionWithAction:skew1];
			id skew2 = [CCSkewTo actionWithDuration:duration skewX:10 skewY:10];
			id ease2 = [CCEaseSineInOut actionWithAction:skew2];
			id sequence = [CCSequence actions:ease2, ease1, nil];
			id repeat = [CCRepeatForever actionWithAction:sequence];
			[webSprite runAction:repeat];
			
			id scale1 = [CCScaleTo actionWithDuration:duration scaleX:1.25f scaleY:0.8f];
			id scale2 = [CCScaleTo actionWithDuration:duration scaleX:1.0f scaleY:0.95f];
			id seq2 = [CCSequence actions:scale2, scale1, nil];
			id rep2 = [CCRepeatForever actionWithAction:seq2];
			[webSprite runAction:rep2];
			
			id tint1 = [CCTintTo actionWithDuration:duration red:0 green:255 blue:0];
			id tint2 = [CCTintTo actionWithDuration:duration red:255 green:0 blue:0];
			id seq3 = [CCSequence actions:tint2, tint1, nil];
			id rep3 = [CCRepeatForever actionWithAction:seq3];
			[webSprite runAction:rep3];
		}
		
		{
			// just for kicks, try to download a file from the world wide web as well
			NSString* localFile = [self downloadFileFromServer:kWorldWideWebServerAddress
													  filename:kWorldWideWebServerFile
													 spriteTag:kTagForWorldWideWebSprites];
			
			CCSprite* flair = [CCSprite spriteWithFile:localFile];
			//flair.position = CGPointMake(480 - flair.contentSize.width * 0.5f, 320 - flair.contentSize.height * 0.5f);
			flair.position = CGPointMake(240, 160);
			flair.opacity = 120; // let the background shine through, gives an eery "desertly" atmosphere
			flair.tag = kTagForWorldWideWebSprites;
			flair.scale = 1.4f;
			[self addChild:flair z:-1];
		}
		
		{
			// this sprite should show the lag in performance caused by download & texture reload
			CCSprite* sprite = [CCSprite spriteWithFile:@"Icon.png"];
			sprite.scale = 0.25f;
			CGPoint spriteOffset = CGPointMake(sprite.contentSize.width * 0.125f, sprite.contentSize.height * 0.125f);
			sprite.position = spriteOffset;
			sprite.color = ccBLACK;
			sprite.opacity = 150;
			[self addChild:sprite z:2];
			
			CGSize screenSize = [CCDirector sharedDirector].winSize;
			float duration = 1.3f;
			id moveR = [CCMoveTo actionWithDuration:duration position:CGPointMake(screenSize.width - spriteOffset.x, sprite.position.y)];
			id moveL = [CCMoveTo actionWithDuration:duration position:sprite.position];
			id sequence = [CCSequence actions:moveR, moveL, nil];
			id repeat = [CCRepeatForever actionWithAction:sequence];
			[sprite runAction:repeat];
		}
		
		{
			CCLabelTTF* label = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:16];
			label.anchorPoint = CGPointMake(0, 1);
			label.position = CGPointMake(2, 318);
			label.color = ccMAGENTA;
			label.tag = kTagForAsyncModeLabel;
			[self addChild:label z:2];
		}
		
		useAsynchronousOperations = rememberAsyncSetting;
		[self updateAsyncModeLabelString];
		
		self.isTouchEnabled = YES;
		[self schedule:@selector(updateWebSprites:) interval:0.2f];
	}
	return self;
}

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

@end
