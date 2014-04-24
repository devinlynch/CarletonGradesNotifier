//
//  GradeTableViewCell.h
//  Grades
//
//  Created by Devin Lynch on 2014-04-23.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Grade;

@interface GradeTableViewCell : UITableViewCell

@property IBOutlet UILabel *courseCode;
@property IBOutlet UILabel *courseName;
@property IBOutlet UILabel *courseGrade;


-(void) updateCellFromGrade: (Grade*) grade;

@end
