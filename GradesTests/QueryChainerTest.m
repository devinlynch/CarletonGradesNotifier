//
//  QueryChainerTest.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-25.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QueryChainer.h"

@interface QueryChainerTest : XCTestCase
{
    QueryChainer *chainer;
}
@end

@implementation QueryChainerTest

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    chainer = [[QueryChainer alloc] init];
    
    [chainer addBlockToChain:^(queryCallback callback) {
        callback(nil, @"1");
    } forName:@"first" withCallback:nil];
    
    [chainer addBlockToChain:^(queryCallback callback) {
        callback(nil, @"2");
    } forName:@"second" withCallback:nil];
    
    [chainer executeAsync:^(NSError* error, NSDictionary *dic) {
        NSLog(@"%@", dic);
    }];
}

@end
