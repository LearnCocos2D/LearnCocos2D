//
//  IntroScene.m
//  Cocos2D-v3.0-alpha-Performance
//
//  Created by Steffen Itterheim on 12/12/13.
//  Copyright Steffen Itterheim 2013. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "IntroScene.h"
#import "HelloWorldLayer.h"

// -----------------------------------------------------------------------
#pragma mark - IntroScene
// -----------------------------------------------------------------------

NSString *preview =
@"Cosos2D Version 3 (preview)\n\n\
For evaluation only\n\
Do not use for new development";

// -----------------------------------------------------------------------

@implementation IntroScene

// -----------------------------------------------------------------------

+ (IntroScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    // Crash if basic initialization for some reason failed
    NSAssert(self, @"Unable to create class IntroScene");
    
    // Here is where custom code for the scene starts
    
	/*
    // create a colored background
    CCLayerColor *background = [CCLayerColor layerWithColor:(ccColor4B){200, 200, 200, 255}];
    [self addChild:background];
    
    // create a string with preview text
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:preview];
    
    // set color and font of the string
    [string addAttribute:NSForegroundColorAttributeName
                   value:[UIColor blackColor]
                   range:NSMakeRange(0, string.length)];
    [string addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:@"Arial" size:22.0f]
                   range:NSMakeRange(0, string.length)];
    
    // create an attributes label, and place it in upper left corner
    CCLabelTTF *label = [CCLabelTTF labelWithAttributedString:string];
    label.positionType = CCPositionTypeNormalized;
    label.position = ccp(0.4f, 0.8f);
    [self addChild:label];
    
    // add a next button
    CCButton *nextButton = [CCButton buttonWithTitle:@"[ Next ]"];
    nextButton.positionType = CCPositionTypeNormalized;
    nextButton.position = ccp(0.9f, 0.9f);
    [nextButton setTarget:self selector:@selector(onNextClicked:)];
    [self addChild:nextButton];
	*/
	
	[self scheduleOnce:@selector(onNextClicked:) delay:0.1];
    // done
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onNextClicked:(CCTime)delta
{
    // start main scene with transition
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

// -----------------------------------------------------------------------
@end