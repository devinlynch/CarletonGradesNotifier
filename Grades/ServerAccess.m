//
//  ServerAccess.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-22.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "ServerAccess.h"

@implementation ServerAccess

typedef enum HttpRequestMethods {
    POSTREQUEST,
    GETREQUEST
} HttpRequestMethods;

+(void) asynchronousRequestOfType: (HttpRequestMethods) method toUrl: (NSString*) targetUrl withParams: (NSDictionary*) params  andErrorCall:(block_t) errorCall andSuccessCall: (block_t) successCall{

    NSString *postBody = [self httpParamsFromDictionary:params];
    NSData *postData = [postBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];

    NSURL *url = [NSURL URLWithString:targetUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod: [self httpethodToString:method]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:20];
    //TODO: handle timeout
    NSOperationQueue *queue =[[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error) {
         
         NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
         int responseStatusCode = (int)[httpResponse statusCode];
                  
         if( data != nil ){
             if(successCall != nil){
                 successCall(data);
             }         } else{
             NSLog(@"could not connect to server, doing call, got response code: %d and error: %@", responseStatusCode, error);
             if(errorCall != nil)
                 errorCall(data);
         }
     }];
}

+(NSString*) httpParamsFromDictionary: (NSDictionary*) dict{
    NSString *returnS = @"";
    
    if(dict == nil)
        return returnS;
    
    NSArray *keyArray =  [dict allKeys];
    int count = (int)[keyArray count];
    for (int i=0; i < count; i++) {
        id tmp = [dict objectForKey:[keyArray objectAtIndex:i]];
        
        if(i != count-1)
            returnS = [returnS stringByAppendingFormat:@"%@=%@&", [keyArray objectAtIndex:i], tmp];
        else
            returnS = [returnS stringByAppendingFormat:@"%@=%@", [keyArray objectAtIndex:i], tmp];
    }
    
    return returnS;
}

+(NSString*) httpethodToString: (HttpRequestMethods) method {
    if(method == GETREQUEST) {
        return @"GET";
    } else{
        return @"POST";
    }
}


+(void) authenticateWithUsername: (NSString*) username andPassword: (NSString*) password withSuccess: (block_t) success andError: (block_t) error{
    NSDictionary *params = @{
                             @"userid": username,
                             @"userpwd": password
                             };
    [self asynchronousRequestOfType:POSTREQUEST toUrl:@"https://mobileapps.carleton.ca:8443/iPhone/login.jsp" withParams:params andErrorCall:error andSuccessCall:success];
}

+(void) getGradesWithUsername: (NSString*) username andToken: (NSString*) token forTerm: (NSString*) termId withSuccess: (block_t) success andError: (block_t) error{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                             @"userid": username,
                             @"key": token
                             }];
    if(termId) {
        [params setObject:termId forKey:@"term"];
    }
    [self asynchronousRequestOfType:POSTREQUEST toUrl:@"https://mobileapps.carleton.ca:8443/iPhone/protected/getGrades" withParams:params andErrorCall:error andSuccessCall:success];
}

@end
