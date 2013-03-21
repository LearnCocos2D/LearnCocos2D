//
//  MRCTests.m
//  Cocos2D-ARC-Performance-Test
//
//  Created by Steffen Itterheim on 20.03.13.
//
//

#import "cocos2d.h"
#import "MRCTests.h"
#import "JASGeneticAlgo.h"

@implementation MRCTests

+(id) mrcTests
{
	return [[[self alloc] init] autorelease];
}

-(void) dealloc
{
	//NSLog(@"MRC Test dealloc");
	[super dealloc]; // this line is illegal under ARC
}

-(void) createAutoreleaseObject
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	CCNode* test = [CCNode node];
	test = nil;
	
	[pool release];
}

-(void) createAllocInitObject
{
	CCNode* test = [[CCNode alloc] init];
	[test release];
	test = nil;
}

-(CCNode*) createAndReturnAutoreleaseObject
{
	return [CCNode node];
}

-(void) messageThatDoesNothing
{
}

// code from:
// http://iphonedevelopment.blogspot.de/2008/04/root-of-all-evil-introduction-to.html
-(BOOL) data:(NSData*)data containsCString:(char *)cmp
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

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
	
	[pool release];
	return retval;
}

-(void) runGeneticAlgorithm
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSString* sequence = @"lks89Ü?c§cngW3d432d7cf143497fb5a95b280f873b16iysöl5cöä#ke2ß0B%	()=BÄ´Qyaix4@\nElapsou5ö8o7	5V4*j6ß71655b7c7b6cb41128dffc046773acfbc8w3y,ic;9uwo9ly8WV)+:.573j 4jpew Q'C)96ß#8m)$VNwv49";
	JASGeneticAlgo *algo = [[JASGeneticAlgo alloc] initWithTargetSequence:sequence];
	[algo execute];
	[algo release];
	
	[pool release];
}

@end
