//
//  GradesFetcher.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-23.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "GradesFetcher.h"
#import "KeychainItemWrapper.h"
#import "ServerAccess.h"
#import "Grade.h"

@implementation GradesFetcher

+(void) fetchGrades{
    KeyValue *kv = [self getStoredUsernameAndPassword];
    NSString *username = kv.key;
    NSString *password = kv.value;
    
    if(username == nil || password == nil)
        return;
    
    
    [self authenticateThenGetGradesWithUsername:username andPassword:password];
}

+(void) authenticateThenGetGradesWithUsername: (NSString*) username andPassword: (NSString*) password{
    block_t error = nil;
    block_t success = ^(NSData* data) {
        NSString *response = [Utils stringFromData:data];
        
        NSRange range1 = [response rangeOfString:@"?token="];
        NSString *secondHalf = [response substringWithRange:NSMakeRange(range1.location+range1.length, 100)];
        NSRange range2 = [secondHalf rangeOfString:@"\""];
        NSString *token = [response substringWithRange:NSMakeRange(range1.location+range1.length, range2.location)];
        
        [self getGradesWithUsername:username andToken:token];
        
    };
    
    [ServerAccess authenticateWithUsername:username andPassword:password withSuccess:success andError:error];
}

+(void) getGradesWithUsername: (NSString*) username andToken: (NSString*) token {
    block_t success = ^(NSData* data) {
        NSDictionary *response;
        @try {
            response = [Utils dictionaryFromJSONData:data];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        
        NSLog(@"%@", response);
        [self parseGradesAndNotify: response];
    };
    
    [ServerAccess getGradesWithUsername:username andToken:token withSuccess:success andError:nil];
}

+(void) parseGradesAndNotify: (NSDictionary*) json{
    NSArray* gradesArr = [json objectForKey:@"grades"];
    if(gradesArr == nil)
        return;
    
    NSMutableArray *grades  = [[NSMutableArray alloc] init];
    for(NSDictionary * gradeDic in gradesArr) {
        Grade *grade = [[Grade alloc] init];
        grade.grade = [gradeDic objectForKey:@"grade"];
        grade.courseDescription = [gradeDic objectForKey:@"courseDescription"];
        grade.courseTitle = [gradeDic objectForKey:@"courseTitle"];
        [grades addObject:grade];
    }
    NSLog(@"%@", grades);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gotGrades" object:grades];
    });
}

+(void) updateUsername: (NSString*) username andPassword: (NSString*) password{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"CarletonGradesChecker" accessGroup:nil];
    [wrapper setObject:username forKey:(__bridge id)kSecAttrAccount];
    [wrapper setObject:password forKey:(__bridge id)kSecValueData];
}

+(KeyValue*) getStoredUsernameAndPassword{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"CarletonGradesChecker" accessGroup:nil];
    KeyValue *kv = [[KeyValue alloc] init];
    kv.key = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    kv.value = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    return kv;
}

@end
