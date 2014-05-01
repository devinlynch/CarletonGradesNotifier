//
//  CacheObject.h
//  Grades
//
//  Created by Devin Lynch on 2014-04-27.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheObject : NSObject

@property NSString *key;
@property id object;
@property NSDate* expiryDate;

@end
