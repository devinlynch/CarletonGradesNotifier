//
//  QueryChainer.h
//  Grades
//
//  Created by Devin Lynch on 2014-04-24.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^queryCallback)(NSError *error, id data);
typedef void (^postQueryCallback)(NSError *error, id data, NSString *queryName);
typedef void (^queryBlock)(queryCallback callback);
typedef void (^queryChainerResultCallback)(NSError *error, NSDictionary *dataDictionary);

@interface QueryChainer : NSObject
{
    NSMutableArray *_blocks;
}

-(void) addBlockToChain: (queryBlock) block forName: (NSString*) name withCallback: (postQueryCallback) callback;
-(void) executeAsync: (queryChainerResultCallback) finalCallback;

@end
