//
//  ZRLanguageViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import "ZRLanguageViewController.h"

@interface ZRLanguageViewController ()
{
    NSMutableArray *arrLanguages;
    NSIndexPath *previousIndex;
    NSString *strSelectedLanguage;
}
@property(nonatomic,strong) IBOutlet UITableView *tblLanguage;

@end

@implementation ZRLanguageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initModel];
    [self initUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    BOOL allowed = NO;
    if(interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        allowed = YES;
    }
    return allowed;
}

//////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
//////////////////////////////////////////////////////////////////////////////////////////////
- (void)initUI
{
    int height = [arrLanguages count] * 44;
    _tblLanguage.frame = CGRectMake(0, 50, 320, height);
    [_tblLanguage reloadData];
}

- (void)initModel
{
    arrLanguages = [[NSMutableArray alloc] initWithObjects:@"English",@"Spanish",@"French", nil];
    previousIndex = nil;
    strSelectedLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_LANGUAGE"];
    if (strSelectedLanguage.length == 0) {
        strSelectedLanguage = @"English";
        [[NSUserDefaults standardUserDefaults] setObject:@"English" forKey:@"SELECTED_LANGUAGE"];
    }
}

- (void)radioButtonTapped:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tblLanguage];
    NSIndexPath *indexPath = [_tblLanguage indexPathForRowAtPoint:buttonPosition];
    if (previousIndex !=nil) {
        UITableViewCell *cell = [_tblLanguage cellForRowAtIndexPath:previousIndex];
        UIButton *btnRadio = (UIButton *)[cell.contentView viewWithTag:1002];
        [btnRadio setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    }
    if (indexPath != nil)
    {
        UITableViewCell *cell = [_tblLanguage cellForRowAtIndexPath:indexPath];
        UIButton *btnRadio = (UIButton *)[cell.contentView viewWithTag:1002];
        [btnRadio setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
        previousIndex = indexPath;
        [[NSUserDefaults standardUserDefaults] setObject:[arrLanguages objectAtIndex:indexPath.row] forKey:@"SELECTED_LANGUAGE"];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark IBActions
//////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)btnBackSelected:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


//////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewDelegate Methods
//////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrLanguages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellDescription = @"languageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellDescription];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellDescription];
    }

    
    UILabel *lblLanguage = (UILabel *)[cell.contentView viewWithTag:1001];
    UIButton *btnRadio = (UIButton *)[cell.contentView viewWithTag:1002];
    
    NSString *strLanguage = [arrLanguages objectAtIndex:indexPath.row];
    lblLanguage.text = strLanguage;
    if ([strLanguage isEqualToString:strSelectedLanguage]) {
        [btnRadio setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
        previousIndex = indexPath;
    }
    else
    {
        [btnRadio setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    }
    [btnRadio addTarget:self action:@selector(radioButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
    }
    else if (indexPath.row == 1)
    {
        
    }
    
}

@end
