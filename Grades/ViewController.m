//
//  ViewController.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-22.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "ViewController.h"
#import "GradesFetcher.h"
#import "Grade.h"
#import "Utils.h"
#import "TermGrades.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize usernameTxt,pwdTxt;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    KeyValue *usernamePass = [GradesFetcher getStoredUsernameAndPassword];
    NSString *username = usernamePass.key;
    NSString *password = usernamePass.value;
    
    if(username != nil) {
        usernameTxt.text = username;
    }
    
    if(password != nil) {
        pwdTxt.text = password;
    }
    
    if(username != nil && password != nil){
        [self authenticate: username andPassword: password];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didPressGo:(id)sender{
    NSString *username = usernameTxt.text;
    NSString *password = pwdTxt.text;
    
    [self authenticate:username andPassword:password];
}

-(void) authenticate: (NSString*) username andPassword: (NSString*) password{
    [Utils showLoaderOnView:self.view animated:YES];
    
    void (^successBlock)(void)= ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utils removeLoaderOnView:self.view animated:YES];
            [self performSegueWithIdentifier:@"loggedIn" sender:self];
        });
    };
    
    void (^errorBlock)(void)= ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utils removeLoaderOnView:self.view animated:YES];
            [Utils showAlertWithTitle:@"Whoops" message:@"Your username and password did not match, or there is an error with the server." delegate:nil cancelButtonTitle:@"Ok"];
        });
    };
    
    [GradesFetcher updateUsername:username andPassword:password];
    
    [GradesFetcher authenticateWithSuccess:^(NSString* token, NSString* username) {
        successBlock();
    }andError:errorBlock];
}

@end
