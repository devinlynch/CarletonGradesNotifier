//
//  Cache.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-27.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "Cache.h"
#import "CacheObject.h"

@implementation Cache

static NSMutableDictionary *_caches;
+(NSMutableDictionary*) caches{
    if(_caches == nil) {
        _caches = [[NSMutableDictionary alloc] init];
    }
    
    return _caches;
}

+(void) addToGlobalCache: (NSString*) key withObject: (id) object andExpiry: (NSDate*) expiryDate{
    [self addToCacheNamed:@"com.devinlynch.GlobalCache" withKey:key withObject:object andExpiry:expiryDate];
}

+(void) addToCacheNamed: (NSString*) cacheName withKey: (NSString*) key withObject: (id) object andExpiry: (NSDate*) expiryDate{
    if(key == nil || cacheName == nil)
        return;
    
    NSMutableDictionary *cache = [self getOrCreateCacheWithName:cacheName];
    
    CacheObject *cacheObject = [[CacheObject alloc] init];
    cacheObject.expiryDate = expiryDate;
    cacheObject.key = key;
    cacheObject.object = object;
    
    [cache setObject:cacheObject forKey:key];
}

+(NSMutableDictionary*) getOrCreateCacheWithName: (NSString*) cacheName {
    NSMutableDictionary *cache = [[self caches] objectForKey:cacheName];
    if(cache != nil)
        return cache;
    
    [[self caches] setObject:[[NSMutableDictionary alloc] init] forKey:cacheName];
    return [[self caches] objectForKey:cacheName];
}

+(id) getFromGlobalCache: (NSString*) key{
     return [self get:key fromCacheNamed:@"com.devinlynch.GlobalCache"];
}

+(id) get: (NSString*) key fromCacheNamed: (NSString*) cacheName {
    if(key == nil || cacheName == nil)
        return nil;
    
    NSMutableDictionary *cache = [[self caches] objectForKey:cacheName];
    if(cache == nil)
        return nil;
    
    CacheObject *cacheObject = [cache objectForKey:key];
    if(cacheObject== nil)
        return cacheObject;
    
    if(cacheObject.expiryDate != nil && [cacheObject.expiryDate compare:[NSDate date]] == NSOrderedAscending) {
        [cache removeObjectForKey:key];
        return nil;
    }
    
    return cacheObject.object;
}

@end
