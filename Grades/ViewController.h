//
//  ViewController.h
//  Grades
//
//  Created by Devin Lynch on 2014-04-22.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property IBOutlet UITextField* usernameTxt;
@property IBOutlet UITextField* pwdTxt;

-(IBAction)didPressGo:(id)sender;

@end
