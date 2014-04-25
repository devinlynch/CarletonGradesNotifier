//
//  QueryBlock.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-25.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "QueryBlock.h"

@implementation QueryBlock

@synthesize name;

-(void) setBlock: (queryBlock) block{
    _block = block;
}

-(void) setCallback: (postQueryCallback) callback{
    _callback = callback;
}

-(queryBlock) getBlock {
    return _block;
}

-(postQueryCallback) getCallback {
    return _callback;
}

@end
