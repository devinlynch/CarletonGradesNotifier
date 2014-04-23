//
//  ViewController.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-22.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "ViewController.h"
#import "GradesFetcher.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didPressGo:(id)sender{
    NSString *username = usernameTxt.text;
    NSString *password = pwdTxt.text;
    
    [GradesFetcher updateUsername:username andPassword:password];
    [GradesFetcher fetchGrades];
}

@end
