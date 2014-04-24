//
//  GradesViewController.m
//  Grades
//
//  Created by Devin Lynch on 2014-04-23.
//  Copyright (c) 2014 Devin Lynch. All rights reserved.
//

#import "GradesViewController.h"
#import "Utils.h"
#import "Grade.h"
#import "TermGrades.h"
#import "GradesFetcher.h"
#import "GradeTableViewCell.h"

@interface GradesViewController ()
{
    TermGrades *termGrades;
    UIRefreshControl *refreshControl;
}
@end

@implementation GradesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadGradesForTerm:nil shouldShowAnimation:YES];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

-(void) refresh:(id)sender{
    if(termGrades != nil)
        [self loadGradesForTerm:termGrades.termId shouldShowAnimation:NO];
    else
        [self loadGradesForTerm:nil shouldShowAnimation:NO];
}

-(void) loadGradesForTerm: (NSString*) termId shouldShowAnimation: (BOOL) shouldShowAnimation {
    if(shouldShowAnimation)
        [Utils showLoaderOnView:self.view animated:YES];
    
    void (^successBlock)(TermGrades* grades)= ^(TermGrades* grades){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(shouldShowAnimation)
                [Utils removeLoaderOnView:self.view animated:YES];
            
            if([refreshControl isRefreshing])
                [refreshControl endRefreshing];
            
            [self updateTerm: grades];
        });
    };
    
    void (^errorBlock)(void)= ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(shouldShowAnimation)
                [Utils removeLoaderOnView:self.view animated:YES];
            if([refreshControl isRefreshing])
                [refreshControl endRefreshing];
            [self showErrorLoadingGrades];
        });
    };
    
    [GradesFetcher fetchGradesWithNewGrade:^(Grade* g){
     } andNoNewGrade:^{
     } allGradesBlock:^(TermGrades* grades){
         successBlock(grades);
     }andError:^{
         errorBlock();
     } forTerm:termId];
}

-(void) showErrorLoadingGrades{
    [Utils showAlertWithTitle:@"Whoops" message:@"There was an error fetching your grades.  Please try again." delegate:nil cancelButtonTitle:@"Ok"];
}

-(void) updateTerm: (TermGrades*) _termGrades {
    termGrades = _termGrades;
    [self updateUIForCurrentTerm];
}

-(void) updateUIForCurrentTerm{
    self.termNameLabel.text = termGrades.termName;
    
    self.nextTermButton.enabled = termGrades.nextTermId != nil;
    self.previousTermButton.enabled = termGrades.previousTermId != nil;
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(IBAction)didPressNextTerm:(id)sender{
    if(termGrades.nextTermId != nil) {
        [self loadGradesForTerm:termGrades.nextTermId shouldShowAnimation:YES];
    }
}

-(IBAction)didPressPreviousTerm:(id)sender{
    if(termGrades.previousTermId != nil) {
        [self loadGradesForTerm:termGrades.previousTermId shouldShowAnimation:YES];
    }
}

#pragma mark - UITableView

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(termGrades == nil || termGrades.grades.count == 0)
        return 1;
    
    return termGrades.grades.count;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int)indexPath.row;
    
    Grade *grade = [termGrades.grades objectAtIndex:index];
    
    if(grade != nil) {
        static NSString *CellIdentifier = @"GradeTableViewCell";
        
        GradeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil){
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GradeTableViewCell" owner:nil options:nil];
            
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[GradeTableViewCell class]])
                {
                    cell = (GradeTableViewCell *)currentObject;
                    break;
                }
            }
        }
        
        [cell updateCellFromGrade:grade];
        
        if(cell!=nil)
            return cell;
    }
    
    NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (defaultCell == nil) {
        defaultCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    defaultCell.textLabel.text = @"No grades yet for this term.";
    return defaultCell;

}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0;
}


@end
