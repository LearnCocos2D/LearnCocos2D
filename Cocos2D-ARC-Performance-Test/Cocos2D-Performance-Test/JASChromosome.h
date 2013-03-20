//
//  JASChromosome.h
//  SimpleGeneticAlgo
//
//  Created by Joshua Smith on 4/3/12.
//  Copyright (c) 2012 iJoshSmith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JASChromosome : NSObject

// Returns a copy of this chromosome's genes.
@property (nonatomic, readonly, strong) NSString *geneSequence;

// Designated initializer.
- (id)initWithGeneCount:(NSUInteger)count;

// Creates a new chromosome based on the gene 
// sequences of this chromosome and another one.
- (JASChromosome *)mateWithChromosome:(JASChromosome *)other;

// Returns YES if this chromosome's fitness is better 
// than the other chromosome's fitness.
- (BOOL)isFitterThanChromosome:(JASChromosome *)other 
             forTargetSequence:(NSString *)sequence;

@end
