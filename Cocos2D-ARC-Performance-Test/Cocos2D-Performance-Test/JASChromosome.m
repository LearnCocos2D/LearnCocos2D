//
//  JASChromosome.m
//  SimpleGeneticAlgo
//
//  Created by Joshua Smith on 4/3/12.
//  Copyright (c) 2012 iJoshSmith. All rights reserved.
//

#import "JASChromosome.h"

#define ARC4RANDOM_MAX     (0x100000000)                    // The highest value returned by arc4random()
#define FIRST_CHAR         (32)                             // ' '
#define LAST_CHAR          (122)                            // 'Z'
#define MUTATION_DELTA_MAX (6)                              // Mutate one gene by no more than +/-5.
#define MUTATION_RATE	    (0.20f)                          // Mutate about 20% of the time
#define MUTATION_THRESHOLD (ARC4RANDOM_MAX * MUTATION_RATE) // This is used to determine if a mutation should occur.
#define RANDOM()           (arc4random())                   // Creates a random positive whole number
#define RANDOM_MOD(__MOD)  (arc4random_uniform(__MOD))      // Creates a random positive whole number no greater than __MOD-1 

@interface JASChromosome ()
@property (nonatomic, strong) NSNumber        *cachedOverallFitness;
@property (nonatomic, strong) NSMutableArray  *fitnessBuffer;
@property (nonatomic, strong) NSMutableString *geneBuffer;

// Calculates the overall fitness of this chromosome's gene sequence, 
// with respect to the target gene sequence.
- (NSInteger)fitnessForTargetSequence:(NSString *)seq;

// Calculates the fitness of one gene in the chromosome.
- (NSInteger)fitnessOfGeneAtIndex:(NSUInteger)geneIndex 
                forTargetSequence:(NSString *)seq;

// Performs a random mutation on one gene in the chromosome.
- (void)mutate;
@end


@implementation JASChromosome

@synthesize cachedOverallFitness;
@synthesize fitnessBuffer;
@synthesize geneBuffer;

@dynamic geneSequence;
- (NSString *)geneSequence
{
    return [NSString stringWithString:geneBuffer];
}

- (id)initWithGeneCount:(NSUInteger)count
{
    self = [super init];
    if (self)
    {
        self.fitnessBuffer = [[NSMutableArray arrayWithCapacity:count] retain];
        self.geneBuffer = [[NSMutableString stringWithCapacity:count] retain];
        for (int geneIndex = 0; geneIndex < count; ++geneIndex) 
        {
            // Append a random character between ' ' and 'Z'.
            int value = RANDOM_MOD(LAST_CHAR - FIRST_CHAR);
            value += FIRST_CHAR;
            NSString *gene = [NSString stringWithFormat:@"%c", value];
            [self.geneBuffer appendString:gene];
        }
    }
    return self;
}

-(void) dealloc
{
	//NSLog(@"dealloc %@", self);
	[self.fitnessBuffer release];
	self.fitnessBuffer = nil;
	[self.geneBuffer release];
	self.geneBuffer = nil;
	self.cachedOverallFitness = nil;
	[super dealloc];
}

- (JASChromosome *)mateWithChromosome:(JASChromosome *)other
{
	// SIMULATE ARC BEHAVIOR
	[other retain];
	
    // Create an empty chromosome.
    JASChromosome *child = [[JASChromosome alloc] initWithGeneCount:0];
    
    // Declare loop variables.
    NSUInteger count = self.geneBuffer.length;
    NSNumber *mine, *theirs;
    JASChromosome *winner;
    unichar geneValue;
    NSString *gene;
    
    // Fill the new chromosome's gene buffer with
    // the fittest genes from both parents.
    for (int i = 0; i < count; ++i)
    {
        // Get the same gene from both chromosomes.
        mine   = [self.fitnessBuffer  objectAtIndex:i];
        theirs = [other.fitnessBuffer objectAtIndex:i];
		
		// SIMULATE ARC BEHAVIOR
		[mine retain];
		[theirs retain];

        // Determine which chromosome's gene is fitter.
        winner = [mine integerValue] > [theirs integerValue] 
        ? self 
        : other;
        
        // Add the winner's gene to the child chromosome.
        geneValue = [winner.geneBuffer characterAtIndex:i];
		
        gene = [NSString stringWithFormat:@"%c", geneValue];
        [child.geneBuffer appendString:gene];
		
		// SIMULATE ARC BEHAVIOR
		[mine release];
		[theirs release];
    }
    
    // Sometimes randomly modify the child's gene sequence.
    if (RANDOM() < MUTATION_THRESHOLD)
    {
        [child mutate];
    }
    
	// SIMULATE ARC BEHAVIOR
	[other release];

    return [child autorelease];
}

- (BOOL)isFitterThanChromosome:(JASChromosome *)other 
             forTargetSequence:(NSString *)seq
{
	// SIMULATE ARC BEHAVIOR
	[other retain];

    NSInteger mine   = [self  fitnessForTargetSequence:seq];
    NSInteger theirs = [other fitnessForTargetSequence:seq];
	
	// SIMULATE ARC BEHAVIOR
	[other release];
	
    return mine > theirs;
}

#pragma mark - Private methods

- (NSInteger)fitnessForTargetSequence:(NSString *)seq
{
    if (!self.cachedOverallFitness)
    {
        // The lower the fitness, the less the 
        // chromosome matches the target sequence. 
        // 0 is a perfect match.
        NSInteger overallFitness = 0, fitness = 0;
        NSNumber *box = nil;
        NSUInteger count = seq.length;
        for (int i = 0; i < count; ++i) 
        {
            fitness = [self fitnessOfGeneAtIndex:i 
                               forTargetSequence:seq];
            box = [NSNumber numberWithInteger:fitness];
            [self.fitnessBuffer addObject:box];
            overallFitness += fitness;
        }
        self.cachedOverallFitness = 
          [NSNumber numberWithInteger:overallFitness];
    }
    return [self.cachedOverallFitness integerValue];
}

- (NSInteger)fitnessOfGeneAtIndex:(NSUInteger)geneIndex 
                forTargetSequence:(NSString *)seq
{
    unichar target = [seq        characterAtIndex:geneIndex];
    unichar actual = [geneBuffer characterAtIndex:geneIndex];
    return abs(target - actual) * -1;
}

- (void)mutate
{
    NSInteger delta = RANDOM_MOD(MUTATION_DELTA_MAX);
    
    // About half the time we should 
    // mutate to a lower character.
    BOOL negate = RANDOM_MOD(2) == 0;
    if (negate)
        delta *= -1;
    
    // Pick a gene at random to mutate.
    NSUInteger geneIndex = RANDOM_MOD(self.geneBuffer.length);
    unichar gene = [self.geneBuffer characterAtIndex:geneIndex];
    
    // Make sure the mutated character is valid.
    unichar proposedGene = gene + delta;
    if (proposedGene < FIRST_CHAR || proposedGene > LAST_CHAR)
        delta *= -1;
    
    // Create and apply the mutated gene.
    unichar value = gene + delta;
    NSString *mutant = [NSString stringWithFormat:@"%c", value];
    NSRange range = (NSRange){ geneIndex, 1 };
    [self.geneBuffer replaceCharactersInRange:range 
                                   withString:mutant];
    
    // Dirty the cached fitness value, in case it's already set.
    self.cachedOverallFitness = nil;
}

@end
