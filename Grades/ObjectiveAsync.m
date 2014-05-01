//
//  ObjectiveAsync.m
//
//  Created by Devin Lynch on 2014-04-24.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "ObjectiveAsync.h"
#import "ObjectiveAsyncStep.h"

@implementation ObjectiveAsync

#pragma mark - Public methods

-(id) init{
    self = [super init];
    if(self) {
        _blocks = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addStepWithBlock: (objectiveAsyncStepBlock) block forName: (NSString*) name withCallback: (objectiveAsyncPostStepCallback) callback {
    ObjectiveAsyncStep *queryBlock = [[ObjectiveAsyncStep alloc] init];
    [queryBlock setBlock:block];
    [queryBlock setCallback:callback];
    [queryBlock setName:name];
    
    [_blocks addObject:queryBlock];
}

-(void) executeSeries: (objectiveAsyncFinalCallback) finalCallback {
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *blocks = [NSMutableArray arrayWithArray:_blocks];
    
    objectiveAsyncPostStepCallback stepCallback = [self createSeriesPostQueryCallbackWithDataDictionary: dataDictionary andBlocks: blocks andFinalCallback:finalCallback];
    
    [self executeNextBlock:blocks withStepCallback:stepCallback];
}

-(void) executeAsync: (objectiveAsyncFinalCallback) finalCallback {
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *blocks = [NSMutableArray arrayWithArray:_blocks];
    __block BOOL isDone = NO;
    
    objectiveAsyncPostStepCallback stepCallback = ^(NSError* error, id data, NSString *queryName) {
        if(isDone)
            return;
        
        if(error) {
            isDone = YES;
            finalCallback(error, nil);
            return;
        }
        
        [dataDictionary setObject:data forKey:queryName];
        
        if(blocks.count == 0) {
            finalCallback(nil, dataDictionary);
            return;
        }
    };
    
    [self executeAllBlocksAsync:blocks withStepCallback:stepCallback];
}

#pragma mark - Private methods

-(objectiveAsyncPostStepCallback) createSeriesPostQueryCallbackWithDataDictionary: (NSMutableDictionary*) dataDictionary andBlocks: (NSMutableArray*) blocks andFinalCallback:  (objectiveAsyncFinalCallback) finalCallback {
    return ^(NSError* error, id data, NSString *queryName) {
        if(error) {
            finalCallback(error, nil);
            return;
        }
        
        [dataDictionary setObject:data forKey:queryName];
        
        if(blocks.count == 0) {
            finalCallback(nil, dataDictionary);
            return;
        }
        
        [self executeNextBlock:blocks withStepCallback:[self createSeriesPostQueryCallbackWithDataDictionary:dataDictionary andBlocks:blocks andFinalCallback:finalCallback]];
    };
}

-(void) executeNextBlock: (NSMutableArray*) blocks withStepCallback: (objectiveAsyncPostStepCallback) stepCallback{
    ObjectiveAsyncStep *queryBlock = blocks.firstObject;
    NSString *name = queryBlock.name;
    [blocks removeObjectAtIndex:0];

    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue1, ^{
        [queryBlock getBlock](^(NSError* error, id data){
            if([queryBlock getCallback] != nil) {
                [queryBlock getCallback](error, data, name);
            }
            
            stepCallback(error, data, name);
        });
    });
}



-(void) executeAllBlocksAsync: (NSMutableArray*) blocks withStepCallback: (objectiveAsyncPostStepCallback) stepCallback{
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    for(ObjectiveAsyncStep* queryBlock in blocks) {
        NSString *name = queryBlock.name;

        dispatch_async(queue1, ^{
            queryBlock.getBlock(^(NSError* error, id data){
                if([queryBlock getCallback] != nil) {
                    [queryBlock getCallback](error, data, name);
                }
                
                @synchronized(blocks) {
                    [blocks removeObject:queryBlock];
                    stepCallback(error, data, name);
                }
            });
        });
   }
    
}


@end
