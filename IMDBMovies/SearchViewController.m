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
#import "SearchResult.h"
#import "MovieDetailController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

#define CELL_MARGIN_LEFT 8.0f;
#define CELL_MARGIN_TOP_BOTTOM 8.0f;


static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SearchDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, assign) CGPoint tableViewOffset;

@end

@implementation SearchViewController {
    
    Search *_search;
    
}

-(instancetype)init {
    
    if (self = [super init]) {
        
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.870 alpha:1.000];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.searchBar addGestureRecognizer:tapGestureRecognizer];
    
    //UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    //[self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    UINib *cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    cellNib = [UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
    
}

-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.searchBar resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource | UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (_search == nil) {
        return 0;
    } else if (_search.isLoading) {
        return 1;
    } else if ([_search.searchResults count] == 0) {
        return 1;
    } else {
        return [_search.searchResults count];
    }
    
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
    
    if (_search.isLoading) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];

        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
        [spinner startAnimating];
        
        return cell;
        
    } else if ([_search.searchResults count] == 0) {
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier forIndexPath:indexPath];
        
    } else {
        
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier];
        cell.layer.borderColor = [UIColor blackColor].CGColor;
        cell.layer.borderWidth = 1.0f;
        
        SearchResult *searchResult = _search.searchResults[indexPath.section];
        [self configureCell:cell forSearchResult:searchResult];
        
        return cell;
    }

}

-(void)configureCell:(UITableViewCell*)cell forSearchResult:(SearchResult*)searchResult {

    UILabel *titleLable = (UILabel*)[cell viewWithTag:101];
    titleLable.text = searchResult.title;
    
    CGRect newRect = titleLable.frame;
    newRect.size.width = self.tableView.frame.size.width - 16.0;
    titleLable.frame = newRect;
    
    //[titleLable sizeToFit];
    
    UILabel *countryYearLabel = (UILabel*)[cell viewWithTag:102];
    countryYearLabel.text = [NSString stringWithFormat:@"%@ - %@", searchResult.country, searchResult.year];
    
    
    UILabel *description = (UILabel*)[cell viewWithTag:104];
    
    description.text = searchResult.plot;
        
    newRect = description.frame;
        
    newRect.size.width = self.tableView.frame.size.width - 16.0;
    description.frame = newRect;
        
    //[description sizeToFit];
    description.hidden = NO;
    
    

    UIImageView *poster = (UIImageView*)[cell viewWithTag:103];
    [poster setImageWithURL:[NSURL URLWithString:searchResult.poster]];
    
}

/*-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_search.searchResults count] > 0) {
        CGFloat cellHeight = 0.0f;
        CGFloat yCursor = CELL_MARGIN_TOP_BOTTOM;
        
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        
        UILabel *titleLable = (UILabel*)[cell viewWithTag:101];
        
        CGFloat titleLableHeight = titleLable.numberOfLines == 0 ? titleLable.frame.size.height : titleLable.numberOfLines * 21.5;
        CGRect titleLabelFrame = titleLable.frame;
        titleLabelFrame.origin.x = CELL_MARGIN_LEFT;
        titleLabelFrame.origin.y = yCursor;
        titleLable.frame = titleLabelFrame;
        
        yCursor += titleLableHeight + 10.0f;
        NSLog(@"%ld", (long)titleLable.numberOfLines);
        
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
            
        yCursor += description.frame.size.height;
        cellHeight = yCursor + CELL_MARGIN_TOP_BOTTOM;
        
        return cellHeight;
        
    } else {
        return 44.0;
    }
    
}*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"ShowMovieDetails" sender:_search.searchResults[indexPath.section]];
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowMovieDetails"]) {
        
        MovieDetailController *movieDetailController = segue.destinationViewController;
        movieDetailController.hidesBottomBarWhenPushed = YES;
        
    }
    
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

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
}

- (void)performSearch
{
    
    _search = [[Search alloc] init];
    _search.delegate = self;
    
    NSLog(@"allocated %@", _search);
    
    [_search performSearchForText:self.searchBar.text completion:^(BOOL success) {
        if (success) {
            //[self.tableView reloadData];
        }
    }];
    
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
    
}

#pragma mark - SearchDelegate

-(void)didReceieveNewSearchResult {

    [self.tableView reloadData];
    
}





@end
