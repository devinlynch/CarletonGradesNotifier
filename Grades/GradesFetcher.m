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
#import "PersistanceManager.h"

@implementation GradesFetcher

+(void) fetchGrades{
    [self fetchGradesWithNewGrade:nil andNoNewGrade:nil andError:nil];
}

+(void)fetchGradesWithNewGrade: (void (^)(Grade *grade)) newGradesBlock andNoNewGrade: (void (^)(void)) noNewGradeBlock andError: (void (^)(void)) errorBlock{
    KeyValue *kv = [self getStoredUsernameAndPassword];
    NSString *username = kv.key;
    NSString *password = kv.value;
    
    if(username == nil || password == nil)
        return;
    
    
    [self authenticateThenGetGradesWithUsername:username andPassword:password withNewGrades:newGradesBlock andNoNewGrade:noNewGradeBlock andError:errorBlock];
}

+(void) authenticateThenGetGradesWithUsername: (NSString*) username andPassword: (NSString*) password withNewGrades: (void (^)(Grade *grade)) newGradesBlock andNoNewGrade: (void (^)(void)) noNewGradeBlock andError: (void (^)(void)) errorBlock{
    block_t error = nil;
    block_t success = ^(NSData* data) {
        NSString *response = [Utils stringFromData:data];
        
        NSRange range1 = [response rangeOfString:@"?token="];
        NSString *secondHalf = [response substringWithRange:NSMakeRange(range1.location+range1.length, 100)];
        NSRange range2 = [secondHalf rangeOfString:@"\""];
        NSString *token = [response substringWithRange:NSMakeRange(range1.location+range1.length, range2.location)];
        
        [self getGradesWithUsername:username andToken:token withNewGrades:newGradesBlock andNoNewGrade:noNewGradeBlock andError:errorBlock];
        
    };
    
    [ServerAccess authenticateWithUsername:username andPassword:password withSuccess:success andError:error];
}

+(void) getGradesWithUsername: (NSString*) username andToken: (NSString*) token withNewGrades: (void (^)(Grade *grade)) newGradesBlock andNoNewGrade: (void (^)(void)) noNewGradeBlock andError: (void (^)(void)) errorBlock{
    block_t success = ^(NSData* data) {
        NSDictionary *response;
        @try {
            response = [Utils dictionaryFromJSONData:data];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        
        NSLog(@"%@", response);
        [self parseGradesAndNotify: response withNewGrades:newGradesBlock andNoNewGrade:noNewGradeBlock andError:errorBlock];
    };
    
    [ServerAccess getGradesWithUsername:username andToken:token withSuccess:success andError:nil];
}

+(void) parseGradesAndNotify: (NSDictionary*) json withNewGrades: (void (^)(Grade *grade)) newGradesBlock andNoNewGrade: (void (^)(void)) noNewGradeBlock andError: (void (^)(void)) errorBlock{
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
        
        Grade *newGrade;
        for(Grade *g in grades) {
            BOOL didGetANewGrade = [self storeAndNotifyIfGradeAdded:g];
            if(didGetANewGrade) {
                newGrade = g;
            }
        }
        
        if(newGradesBlock && newGrade) {
            newGradesBlock(newGrade);
        }
        if(noNewGradeBlock && newGrade==nil) {
            noNewGradeBlock();
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gotGrades" object:grades];
    });
}

+(BOOL) storeAndNotifyIfGradeAdded: (Grade*) grade {
    PersistanceManager *manager = [[PersistanceManager alloc] init];
    
    BOOL isStored = [manager isGradeAlreadyStored:grade];
    if(isStored)
        return NO;
    
    [manager saveGrade:grade];
    [self notifyGradeAdded: grade];
    
    return YES;
}

+(void) notifyGradeAdded: (Grade*) grade{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [NSDate date];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:@"New grade for %@: %@",
                            grade.courseTitle, grade.grade];
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
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
