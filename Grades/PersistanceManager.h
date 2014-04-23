//
//  PersistanceManager.h
//  Grades
//
//  Created by Devin Lynch on 2014-04-23.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class Grade;

@interface PersistanceManager : NSObject
{
    NSString *databasePath;
    sqlite3 *database;
}

- (void) saveGrade:(Grade*)grade;
- (BOOL) isGradeAlreadyStored:(Grade *)grade;

@end
