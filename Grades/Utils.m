//
//  Utils.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-22.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+(NSDictionary*) dictionaryFromJSONData: (NSData* ) data{
    NSError *error;
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) {
        NSLog(@"Error parsing JSON: %@", error);
    }
    return json;
}

+(NSString*) stringFromData: (NSData* ) data{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
