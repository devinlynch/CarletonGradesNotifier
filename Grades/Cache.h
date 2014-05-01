//
//  Cache.h
//  Grades
//
//  Created by Devin Lynch on 2014-04-27.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cache : NSObject

+(void) addToGlobalCache: (NSString*) key withObject: (id) object andExpiry: (NSDate*) expiryDate;
+(void) addToCacheNamed: (NSString*) cacheName withKey: (NSString*) key withObject: (id) object andExpiry: (NSDate*) expiryDate;

+(id) getFromGlobalCache: (NSString*) key;
+(id) get: (NSString*) key fromCacheNamed: (NSString*) cacheName;

@end
