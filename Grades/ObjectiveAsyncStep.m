//
//  ObjectiveAsyncStep.m
//
//  Created by Devin Lynch on 2014-04-25.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "ObjectiveAsyncStep.h"

@implementation ObjectiveAsyncStep

@synthesize name;

-(void) setBlock: (objectiveAsyncStepBlock) block{
    _block = block;
}

-(void) setCallback: (objectiveAsyncPostStepCallback) callback{
    _callback = callback;
}

-(objectiveAsyncStepBlock) getBlock {
    return _block;
}

-(objectiveAsyncPostStepCallback) getCallback {
    return _callback;
}

@end
