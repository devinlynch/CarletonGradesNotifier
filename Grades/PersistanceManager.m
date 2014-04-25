//
//  PersistanceManager.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-23.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "PersistanceManager.h"
#import "Grade.h"

@implementation PersistanceManager

-(id) init{
    self=[super init];
    
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    databasePath = [[NSString alloc]
     initWithString: [docsDir stringByAppendingPathComponent:
                      @"carletonGradesDB1.db"]];
    
    return self;
}

-(void) createDatabaseIfNeeded{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS grade (courseCode TEXT, grade TEXT, termId TEXT)";
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            } else{
                NSLog(@"Succeeded to create table");
            }
            sqlite3_close(database);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
}

- (void) saveGrade:(Grade*)grade
{
    [self createDatabaseIfNeeded];
    
    sqlite3_stmt    *statement;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO grade (courseCode, grade, termId) VALUES (\"%@\", \"%@\", \"%@\")",
                               grade.courseTitle, grade.grade, grade.termId];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,
                           -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Grade added");
            
        } else {
            NSLog(@"Failed to add grade");
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}

- (BOOL) isGradeAlreadyStored:(Grade *)grade
{
    [self createDatabaseIfNeeded];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT courseCode, grade, termId FROM grade where courseCode=\"%@\" AND grade=\"%@\" AND termId=\"%@\"", grade.courseTitle, grade.grade, grade.termId];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                    return YES;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    return NO;
}

@end
