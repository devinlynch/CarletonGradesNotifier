//
//  ObjectiveAsyncStep.h
//
//  Created by Devin Lynch on 2014-04-25.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//
//  Utility class for ObjectiveAsync.  This holds data pertaining to a step in the queue.

#import <Foundation/Foundation.h>
#import "ObjectiveAsync.h"

@interface ObjectiveAsyncStep : NSObject
{
    objectiveAsyncStepBlock _block;
    objectiveAsyncPostStepCallback _callback;
}

@property NSString* name;

-(void) setBlock: (objectiveAsyncStepBlock) block;
-(void) setCallback: (objectiveAsyncPostStepCallback) callback;
-(objectiveAsyncStepBlock) getBlock;
-(objectiveAsyncPostStepCallback) getCallback;

@end
