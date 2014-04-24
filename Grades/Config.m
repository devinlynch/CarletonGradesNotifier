//
//  Config.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-24.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "Config.h"

@implementation Config

static NSDictionary *_config;

+(NSDictionary*) config {
    if(_config == nil) {
        _config = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"]];
    }
    return _config;
}

+(NSString*) configForKey: (NSString*) key{
    return [[self config] objectForKey:key];
}

@end
