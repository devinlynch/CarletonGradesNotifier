//
//  GradesViewController.h
//  Grades
//
//  Created by Devin Lynch on 2014-04-23.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GradesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property IBOutlet UILabel* termNameLabel;
@property IBOutlet UITableView* tableView;
@property IBOutlet UIButton* nextTermButton;
@property IBOutlet UIButton* previousTermButton;

-(IBAction)didPressNextTerm:(id)sender;
-(IBAction)didPressPreviousTerm:(id)sender;

@end
