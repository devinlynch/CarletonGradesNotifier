//
//  QueryChainer.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-24.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "QueryChainer.h"
#import "QueryBlock.h"

@implementation QueryChainer

-(id) init{
    self = [super init];
    if(self) {
        _blocks = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addBlockToChain: (queryBlock) block forName: (NSString*) name withCallback: (postQueryCallback) callback {
    QueryBlock *queryBlock = [[QueryBlock alloc] init];
    [queryBlock setBlock:block];
    [queryBlock setCallback:callback];
    [queryBlock setName:name];
    
    [_blocks addObject:queryBlock];
}

-(void) executeAsync: (queryChainerResultCallback) finalCallback {
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *blocks = [NSMutableArray arrayWithArray:_blocks];
    
    postQueryCallback stepCallback = [self createPostQueryCallbackWithDataDictionary: dataDictionary andBlocks: blocks andFinalCallback:finalCallback];
    
    [self executeNextBlock:blocks withStepCallback:stepCallback];
}

-(postQueryCallback) createPostQueryCallbackWithDataDictionary: (NSMutableDictionary*) dataDictionary andBlocks: (NSMutableArray*) blocks andFinalCallback:  (queryChainerResultCallback) finalCallback {
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
        
        [self executeNextBlock:blocks withStepCallback:[self createPostQueryCallbackWithDataDictionary:dataDictionary andBlocks:blocks andFinalCallback:finalCallback]];
    };
}

-(void) executeNextBlock: (NSMutableArray*) blocks withStepCallback: (postQueryCallback) stepCallback{
    QueryBlock *queryBlock = blocks.firstObject;
    NSString *name = queryBlock.name;
    [blocks removeObjectAtIndex:0];

    [queryBlock getBlock](^(NSError* error, id data){
        if([queryBlock getCallback] != nil) {
            [queryBlock getCallback](error, data, name);
        }
        
        stepCallback(error, data, name);
    });
}

@end
