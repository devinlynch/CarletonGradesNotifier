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
+(void) showAlertWithTitle: (NSString* ) title message: (NSString*) message delegate: (id) delegate cancelButtonTitle: (NSString*) cancelButtonTitle;
+(void) showLoaderOnView: (UIView*) view animated: (BOOL) animated;
+(void) removeLoaderOnView: (UIView*) view animated: (BOOL) animated;
@end
