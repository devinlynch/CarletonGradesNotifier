//
//  GradesFetcher.h
//  Grades
//
//  Created by Devin Lynch on 2014-04-23.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Grade;
@interface GradesFetcher : NSObject

+(void) fetchGrades;
+(void) updateUsername: (NSString*) username andPassword: (NSString*) password;
+(KeyValue*) getStoredUsernameAndPassword;

+(void)fetchGradesWithNewGrade: (void (^)(Grade *grade)) newGradesBlock andNoNewGrade: (void (^)(void)) noNewGradeBlock andError: (void (^)(void)) errorBlock;

@end
