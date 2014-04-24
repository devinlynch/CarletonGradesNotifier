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
#import "TermGrades.h"

@implementation GradesFetcher

static NSString *_cachedToken;
static NSString *_cachedUsername;
+(void) setCachedToken: (NSString*) token{
    _cachedToken = token;
}
+(void) setCachedUsername: (NSString*) username{
    _cachedUsername = username;
}

+(void) fetchGradesForTerm: (NSString*) termId withGotGradesSuccess: (void (^)(TermGrades *grades)) success andErrorBlock: (void (^)(void)) errorBlock{
    [self fetchGradesWithNewGrade:nil andNoNewGrade:nil allGradesBlock:success andError:errorBlock forTerm:termId];
}

+(void) authenticateWithSuccess: (void (^)(NSString *token, NSString* username)) successBlock andError: (void (^)(void)) errorBlock{
    KeyValue *kv = [self getStoredUsernameAndPassword];
    NSString *username = kv.key;
    NSString *password = kv.value;
    
    if(username == nil || password == nil)
        return;
    
    block_t error = ^(NSData* data) {
        errorBlock();
    };
    
    block_t success = ^(NSData* data) {
        NSString *response = [Utils stringFromData:data];
        
        NSString *token;
        @try {
            NSRange range1 = [response rangeOfString:@"?token="];
            NSString *secondHalf = [response substringWithRange:NSMakeRange(range1.location+range1.length, 100)];
            NSRange range2 = [secondHalf rangeOfString:@"\""];
            token = [response substringWithRange:NSMakeRange(range1.location+range1.length, range2.location)];
        }
        @catch (NSException *exception) {
            errorBlock();
            return;
        }
        
        [self setCachedToken:token];
        [self setCachedUsername:username];
        
        successBlock(token, username);
    };
    
    [ServerAccess authenticateWithUsername:username andPassword:password withSuccess:success andError:error];
}

+(void)fetchGradesWithNewGrade: (void (^)(Grade *grade)) newGradesBlock andNoNewGrade: (void (^)(void)) noNewGradeBlock allGradesBlock: (void (^)(TermGrades *grades)) allGradesBlock andError: (void (^)(void)) errorBlock forTerm: (NSString*) termId{
    
    if(_cachedToken != nil && _cachedUsername != nil) {
        [self getGradesWithUsername:_cachedUsername andToken:_cachedToken forTerm:termId withNewGrades:newGradesBlock andNoNewGrade:noNewGradeBlock allGradesBlock:allGradesBlock andError:errorBlock];
    } else{
        [self authenticateWithSuccess:^(NSString* token, NSString* username) {
            [self getGradesWithUsername:username andToken:token forTerm:termId withNewGrades:newGradesBlock andNoNewGrade:noNewGradeBlock allGradesBlock:allGradesBlock andError:errorBlock];
        }andError:errorBlock];
    }
}

+(void) getGradesWithUsername: (NSString*) username andToken: (NSString*) token forTerm: (NSString*) termId withNewGrades: (void (^)(Grade *grade)) newGradesBlock andNoNewGrade: (void (^)(void)) noNewGradeBlock allGradesBlock: (void (^)(TermGrades *grades)) allGradesBlock andError: (void (^)(void)) errorBlock{
    block_t success = ^(NSData* data) {
        NSDictionary *response;
        @try {
            response = [Utils dictionaryFromJSONData:data];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
            errorBlock();
            return;
        }
        
        NSLog(@"%@", response);
        [self parseGradesAndNotify: response withNewGrades:newGradesBlock andNoNewGrade:noNewGradeBlock allGradesBlock:allGradesBlock andError:errorBlock];
    };
    
    [ServerAccess getGradesWithUsername:username andToken:token forTerm:termId withSuccess:success andError:^(NSData* data) {
        errorBlock();
    }];
}

+(void) parseGradesAndNotify: (NSDictionary*) json withNewGrades: (void (^)(Grade *grade)) newGradesBlock andNoNewGrade: (void (^)(void)) noNewGradeBlock allGradesBlock: (void (^)(TermGrades *grades)) allGradesBlock andError: (void (^)(void)) errorBlock{
    NSArray* gradesArr = [json objectForKey:@"grades"];
    if(gradesArr == nil)
        return;
    
    NSDictionary *termDic = [json objectForKey:@"term"];
    NSString *termId = [termDic objectForKey:@"id"];
    NSString *termName = [termDic objectForKey:@"name"];
    NSString *nextTermId = [json objectForKey:@"nextTermId"];
    NSString *prevTermId = [json objectForKey:@"previousTermId"];
    
    TermGrades *termGrades = [[TermGrades alloc] init];
    [termGrades setTermId:termId];
    [termGrades setTermName:termName];
    
    if(nextTermId && [nextTermId isKindOfClass:[NSString class]] && [nextTermId rangeOfString:@"null"].location == NSNotFound) {
        [termGrades setNextTermId:nextTermId];
    }
    if(prevTermId && [prevTermId isKindOfClass:[NSString class]] && [prevTermId rangeOfString:@"null"].location == NSNotFound) {
        [termGrades setPreviousTermId:prevTermId];
    }
    
    for(NSDictionary * gradeDic in gradesArr) {
        Grade *grade = [[Grade alloc] init];
        grade.grade = [gradeDic objectForKey:@"grade"];
        grade.courseDescription = [gradeDic objectForKey:@"courseDescription"];
        grade.courseTitle = [gradeDic objectForKey:@"courseTitle"];
        grade.termId = termId;
        [termGrades addGrade:grade];
    }
    NSLog(@"%@", termGrades.grades);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        Grade *newGrade;
        for(Grade *g in termGrades.grades) {
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
        
        allGradesBlock(termGrades);
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
