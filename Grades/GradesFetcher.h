//
//  GradesFetcher.h
//  Grades
//
//  Created by Devin Lynch on 2014-04-23.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Grade, TermGrades;
@interface GradesFetcher : NSObject

+(void) fetchGradesForTerm: (NSString*) termId withGotGradesSuccess: (void (^)(TermGrades *grades)) success andErrorBlock: (void (^)(void)) errorBlock;
+(void) updateUsername: (NSString*) username andPassword: (NSString*) password;
+(KeyValue*) getStoredUsernameAndPassword;
+(void)fetchGradesWithNewGrade: (void (^)(Grade *grade)) newGradesBlock andNoNewGrade: (void (^)(void)) noNewGradeBlock allGradesBlock: (void (^)(TermGrades *grades)) allGradesBlock andError: (void (^)(void)) errorBlock forTerm: (NSString*) termId;
+(void) authenticateWithSuccess: (void (^)(NSString *token, NSString* username)) successBlock andError: (void (^)(void)) errorBlock;

@end
