//
//  GradeTableViewCell.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-23.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "GradeTableViewCell.h"
#import "Grade.h"

@implementation GradeTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) updateCellFromGrade: (Grade*) grade {
    self.courseCode.text = grade.courseTitle != nil ? grade.courseTitle : @"";
    self.courseName.text = grade.courseDescription != nil ? grade.courseDescription : @"";
    self.courseGrade.text = grade.grade != nil ? grade.grade : @"";
}

@end
