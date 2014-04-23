//
//  Utils.h
//  Grades
//
//  Created by Devin Lynch on 2014-04-22.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyValue.h"

@interface Utils : NSObject
+(NSDictionary*) dictionaryFromJSONData: (NSData* ) data;
+(NSString*) stringFromData: (NSData* ) data;

@end
