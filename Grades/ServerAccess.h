//
//  ServerAccess.h
//  Grades
//
//  Created by Devin Lynch on 2014-04-22.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^block_t)(NSData* response);
@interface ServerAccess : NSObject

+(void) authenticateWithUsername: (NSString*) username andPassword: (NSString*) password withSuccess: (block_t) success andError: (block_t) error;
+(void) getGradesWithUsername: (NSString*) username andToken: (NSString*) token forTerm: (NSString*) termId withSuccess: (block_t) success andError: (block_t) error;

@end
