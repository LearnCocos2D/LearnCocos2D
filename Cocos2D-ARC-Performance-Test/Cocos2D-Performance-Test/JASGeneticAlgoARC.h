//
//  JASGeneticAlgo.h
//  SimpleGeneticAlgo
//
//  Created by Joshua Smith on 4/3/12.
//  Copyright (c) 2012 iJoshSmith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JASGeneticAlgoARC : NSObject

// These properties are used only for displaying the results of execution in the UI.
@property (nonatomic, readonly, assign) NSInteger generations;
@property (nonatomic, readonly, strong) NSString *result;

// Designated initializer
- (id)initWithTargetSequence:(NSString *)sequence;

// Runs the genetic algorithm to generate a string that matches the target sequence.
- (void)execute;

@end
