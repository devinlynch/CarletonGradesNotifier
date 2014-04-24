//
//  Utils.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-22.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "Utils.h"
#import "MBProgressHUD.h"

@implementation Utils

+(NSDictionary*) dictionaryFromJSONData: (NSData* ) data{
    NSError *error;
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) {
        NSLog(@"Error parsing JSON: %@", error);
    }
    return json;
}

+(NSString*) stringFromData: (NSData* ) data{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+(void) showAlertWithTitle: (NSString* ) title message: (NSString*) message delegate: (id) delegate cancelButtonTitle: (NSString*) cancelButtonTitle {
    runOnMainQueueWithoutDeadlocking(^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:delegate
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles: nil];
        @try {
            [alert show];
        }
        @catch (NSException *exception) {
        }
        
    });
}

+(void) showLoaderOnView: (UIView*) view animated: (BOOL) animated{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:view animated:animated];
    });
}

+(void) removeLoaderOnView: (UIView*) view animated: (BOOL) animated{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:view animated:animated];
    });
}

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
