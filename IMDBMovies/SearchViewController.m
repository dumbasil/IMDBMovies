//
//  FirstViewController.m
//  IMDBMovies
//
//  Created by Василий Думанов on 06.12.14.
//  Copyright (c) 2014 Vasily Dumanov. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultCell.h"
#import "Search.h"

#define CELL_MARGIN_LEFT 8.0f;
#define CELL_MARGIN_TOP_BOTTOM 8.0f;


static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController {
    
    Search *_search;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.870 alpha:1.000];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    //UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    //[self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    UINib *cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    cellNib = [UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource | UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 10.0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 2.0;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier];
    cell.layer.borderColor = [UIColor blackColor].CGColor;
    cell.layer.borderWidth = 1.0f;
    
   /* UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Movie Title";
    titleLabel.font = [UIFont systemFontOfSize:12.0f];
    titleLabel.numberOfLines = 1;
    titleLabel.baselineAdjustment = YES;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    
    CGRect titleFrame = titleLabel.frame;
    titleFrame.origin.x = 100.0f;
    titleFrame.origin.y = 100.0f;
    titleLabel.frame = titleFrame;
    
    [cell addSubview:titleLabel];*/
    
    UILabel *description = (UILabel*)[cell viewWithTag:104];
    description.preferredMaxLayoutWidth = 100.0f;
    description.text = @"Сколько лет прошло. все о том же гудят провода, все того же ждут самолеты.";
        
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat cellHeight = 0.0f;
    CGFloat yCursor = CELL_MARGIN_TOP_BOTTOM;
    
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *titleLable = (UILabel*)[cell viewWithTag:101];
    
    CGRect titleLabelFrame = titleLable.frame;
    titleLabelFrame.origin.x = CELL_MARGIN_LEFT;
    titleLabelFrame.origin.y = yCursor;
    titleLable.frame = titleLabelFrame;
    
    yCursor += titleLable.frame.size.height + 10.0f;
    
    UILabel *countryYearLabel = (UILabel*)[cell viewWithTag:102];
    
    CGRect countryYearLabelFrame = countryYearLabel.frame;
    countryYearLabelFrame.origin.x = CELL_MARGIN_LEFT;
    countryYearLabelFrame.origin.y = yCursor;
    countryYearLabel.frame = countryYearLabelFrame;
    
    yCursor += countryYearLabel.frame.size.height + 10.0f;
    
    UIImageView *poster = (UIImageView*)[cell viewWithTag:103];
    
    CGRect posterFrame = poster.frame;
    posterFrame.origin.x = CELL_MARGIN_LEFT;
    posterFrame.origin.y = yCursor;
    poster.frame = posterFrame;
    
    yCursor += poster.frame.size.height + 10.0f;
    
    UILabel *description = (UILabel*)[cell viewWithTag:104];
    
    CGRect descriptionFrame = description.frame;
    descriptionFrame.origin.x = CELL_MARGIN_LEFT;
    descriptionFrame.origin.y = yCursor;
    description.frame = descriptionFrame;
    
    cellHeight = yCursor + description.frame.size.height + CELL_MARGIN_TOP_BOTTOM;
    
    return cellHeight;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - UISearchBarDelegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self performSearch];
}

- (void)performSearch
{
    
    _search = [[Search alloc] init];
    
    NSLog(@"allocated %@", _search);
    
    [_search performSearchForText:self.searchBar.text];
    
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
    
}





@end
