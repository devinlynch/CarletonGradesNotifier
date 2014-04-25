//
//  QueryBlock.h
//  Grades
//
//  Created by Devin Lynch on 2014-04-25.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QueryChainer.h"

@interface QueryBlock : NSObject
{
    queryBlock _block;
    postQueryCallback _callback;
}

@property NSString* name;

-(void) setBlock: (queryBlock) block;
-(void) setCallback: (postQueryCallback) callback;
-(queryBlock) getBlock;
-(postQueryCallback) getCallback;

@end
