//
//  TermGrades.h
//  Grades
//
//  Created by Devin Lynch on 2014-04-23.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Grade;

@interface TermGrades : NSObject

@property NSMutableArray *grades;
@property NSString *termName;
@property NSString *termId;
@property NSString *nextTermId;
@property NSString *previousTermId;

-(void) addGrade:(Grade*) grade;

@end
