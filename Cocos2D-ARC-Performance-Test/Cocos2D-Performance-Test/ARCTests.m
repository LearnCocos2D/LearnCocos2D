//
//  ARCTests.m
//  Cocos2D-ARC-Performance-Test
//
//  Created by Steffen Itterheim on 20.03.13.
//
//

#import "cocos2d.h"
#import "ARCTests.h"

#import "JASGeneticAlgoARC.h"

@implementation ARCTests

+(id) arcTests
{
	return [[self alloc] init];
}

-(void) dealloc
{
	//NSLog(@"ARC Test dealloc");
}

-(void) createAutoreleaseObject
{
	@autoreleasepool
	{
		CCNode* test = [CCNode node];
		test = nil;
	}
}

-(void) createAllocInitObject
{
	CCNode* test = [[CCNode alloc] init];
	test = nil;
}

-(CCNode*) createAndReturnAutoreleaseObject
{
	return [CCNode node];
}

-(void) messageThatDoesNothing
{
}

// code from Jeff LaMarche:
// http://iphonedevelopment.blogspot.de/2008/04/root-of-all-evil-introduction-to.html
-(BOOL) data:(NSData*)data containsCString:(char *)cmp
{
	@autoreleasepool
	{
		BOOL retval = NO;
		NSUInteger offset = 0;
		char * byte;
		const char * bytes = [data bytes];
		
		while (offset < [data length])
		{
			byte = (char *)bytes;
			
			NSString * checkString = [NSString stringWithCString:byte encoding:NSUTF8StringEncoding];
			if ([checkString isEqualToString:[NSString stringWithCString:cmp encoding:NSUTF8StringEncoding]])
			{
				retval = YES;
				break;
			}
			
			offset++;
		}
		return retval;
	}
}

-(void) runGeneticAlgorithm
{
	@autoreleasepool
	{
		NSString* sequence = @"lks89Ü?c§cngW3d432d7cf143497fb5a95b280f873b16iysöl5cöä#ke2ß0B%	()=BÄ´Qyaix4@\nElapsou5ö8o7	5V4*j6ß71655b7c7b6cb41128dffc046773acfbc8w3y,ic;9uwo9ly8WV)+:.573j 4jpew Q'C)96ß#8m)$VNwv49";
		JASGeneticAlgoARC *algo = [[JASGeneticAlgoARC alloc] initWithTargetSequence:sequence];
		[algo execute];
	}
}

@end
