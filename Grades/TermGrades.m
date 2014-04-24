//
//  TermGrades.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-23.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "TermGrades.h"
#import "Grade.h"

@implementation TermGrades
@synthesize termId,grades,nextTermId,previousTermId,termName;

-(id) init{
    self = [super init];
    
    grades = [[NSMutableArray alloc] init];
    
    return self;
}

-(void) addGrade:(Grade*) grade{
    [grades addObject:grade];
}

@end
