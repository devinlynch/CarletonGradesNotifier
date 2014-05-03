//
//  ObjectiveAsync.h
//
//  Created by Devin Lynch on 2014-04-24.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//
//  A simple and readable way to execute asynchronous tasks in parallel or in sequence

#import <Foundation/Foundation.h>

typedef void (^objectiveAsyncStepCallback)(NSError *error, id data);
typedef void (^objectiveAsyncPostStepCallback)(NSError *error, id data, NSString *queryName);
typedef void (^objectiveAsyncStepBlock)(objectiveAsyncStepCallback callback);
typedef void (^objectiveAsyncFinalCallback)(NSError *error, NSDictionary *dataDictionary);

@interface ObjectiveAsync : NSObject
{
    NSMutableArray *_blocks;
}

/*
    Add a step to the list that will be executed.
 
    Parameters:
        block -         The actual block that will get executed.  It must take a objectiveAsyncStepCallback as a parameter and
                        this callback MUST be called from within the block.  Calling this callback with an error not nil will
                        cause the execution of all other steps to be haulted and a call to the final callback.  Calling the callback
                        with no error will cause the data given to be added to the final data dictionary, mapped with the given name
        name -          The name that will be used as the key in the final data dictionary, mapped with the data sent to the callback
                        of the given block
        callback -      An OPTIONAL callback that will be called after successful completion of this step
*/
-(void) addStepWithBlock: (objectiveAsyncStepBlock) block forName: (NSString*) name withCallback: (objectiveAsyncPostStepCallback) callback;

/*
    In order of the steps that were added, executes each step in series.  In other words, each step only occurs AFTER the previous step
    successfully completes.
 
    Parameters:
        finalCallback - This is called once all steps have completed, or when an error was found in one of the steps.  The dictionary
                        will contain the names of the steps mapped with their returned data.
*/
-(void) executeSeries: (objectiveAsyncFinalCallback) finalCallback;

/*
    All the steps added are sent triggered to be called simultaneously.  The final callback will be called once every step has
    compelted or when an error occurs.
 
    Parameters:
        finalCallback - This is called once all steps have completed, or when an error was found in one of the steps.  The dictionary
                        will contain the names of the steps mapped with their returned data.
*/
-(void) executeAsync: (objectiveAsyncFinalCallback) finalCallback;

@end
