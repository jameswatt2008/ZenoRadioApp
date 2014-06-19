//
//  ZRLocationViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import "ZRLocationViewController.h"

@interface ZRLocationViewController ()
{
    NSMutableArray *arrLocations;
    NSIndexPath *previousIndex;
    NSString *strSelectedLocation;
}
@property(nonatomic,strong) IBOutlet UITableView *tblLocation;
@end

@implementation ZRLocationViewController

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
    int height = [arrLocations count] * 44;
    if (height > _tblLocation.frame.size.height) {
        height = _tblLocation.frame.size.height;
    }
    _tblLocation.frame = CGRectMake(0, 50, 320, height);
    [_tblLocation reloadData];
}

- (void)initModel
{
    previousIndex = nil;
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Countries" ofType:@"plist"]];
    NSLog(@"dictionary = %@", dictionary);
    NSArray *array = [dictionary objectForKey:@"Countries"];
    arrLocations = [[NSMutableArray alloc] initWithArray:array];
    
    strSelectedLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_LOCATION"];
    if (strSelectedLocation.length == 0) {
        strSelectedLocation = @"UNITED STATES";
        [[NSUserDefaults standardUserDefaults] setObject:@"UNITED STATES" forKey:@"SELECTED_LOCATION"];
    }
    
}

- (void)radioButtonTapped:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tblLocation];
    NSIndexPath *indexPath = [_tblLocation indexPathForRowAtPoint:buttonPosition];
    if (previousIndex !=nil) {
        UITableViewCell *cell = [_tblLocation cellForRowAtIndexPath:previousIndex];
        UIButton *btnRadio = (UIButton *)[cell.contentView viewWithTag:1002];
        [btnRadio setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    }
    if (indexPath != nil)
    {
        UITableViewCell *cell = [_tblLocation cellForRowAtIndexPath:indexPath];
        UIButton *btnRadio = (UIButton *)[cell.contentView viewWithTag:1002];
        [btnRadio setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
        previousIndex = indexPath;
        [[NSUserDefaults standardUserDefaults] setObject:[arrLocations objectAtIndex:indexPath.row] forKey:@"SELECTED_LOCATION"];
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
    return [arrLocations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellDescription = @"locationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellDescription];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellDescription];
    }
    UILabel *lblLanguage = (UILabel *)[cell.contentView viewWithTag:1001];
    UIButton *btnRadio = (UIButton *)[cell.contentView viewWithTag:1002];
    
    NSString *strCapitalizedCountry = [arrLocations objectAtIndex:indexPath.row];
    lblLanguage.text = [[strCapitalizedCountry lowercaseString] capitalizedString];
    
    if ([[[strSelectedLocation lowercaseString] capitalizedString] isEqualToString:[[strCapitalizedCountry lowercaseString] capitalizedString]]) {
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
