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
#import "Movie.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <CoreData/CoreData.h>

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString * const LoadingCellIdentifier = @"LoadingCell";

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SearchDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIImageView *logo;

@end

@implementation SearchViewController {
    
    Search *_search;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.870 alpha:1.000];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [UIColor clearColor];

    [self showIMDBLogo];
    [self.searchBar becomeFirstResponder];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.searchBar addGestureRecognizer:tapGestureRecognizer];
    
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    cellNib = [UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
    
}

-(void)showIMDBLogo {
    
    self.logo.hidden = NO;
    
    CGFloat goalY = self.logo.center.y;
    self.logo.center = CGPointMake(self.view.frame.size.width / 2.0, CGRectGetMaxY(self.view.frame) + self.logo.frame.size.height / 2.0f);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.logo.center = CGPointMake(self.logo.center.x, goalY);
    }];
    
}

-(void)hideIMDBLogo {
    
    CGFloat goalY = CGRectGetMaxY(self.view.frame) + self.logo.frame.size.height / 2.0f;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.logo.center = CGPointMake(self.logo.center.x, goalY);
    } completion:^(BOOL finished) {
        self.logo.hidden = YES;
    }];
    
}

-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.searchBar resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    //[self.tableView reloadData];
    
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
        self.tableView.scrollEnabled = NO;
        return 1;
    } else if ([_search.searchResults count] == 0) {
        self.tableView.scrollEnabled = NO;
        return 1;
    } else {
        self.tableView.scrollEnabled = YES;
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
        cell.backgroundColor = [UIColor colorWithWhite:0.870 alpha:1.000];

        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
        [spinner startAnimating];
        
        return cell;
        
    } else if ([_search.searchResults count] == 0) {
        UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier];
        cell.backgroundColor = [UIColor colorWithWhite:0.870 alpha:1.000];
        
        return cell;
        
    } else {
        
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier];
        cell.layer.borderColor = [UIColor purpleColor].CGColor;
        cell.layer.borderWidth = 2.0f;
        SearchResult *searchResult = _search.searchResults[indexPath.section];
        [self configureCell:cell forSearchResult:searchResult];
        
        cell.layer.cornerRadius = 10;
        cell.layer.masksToBounds = YES;
        
        return cell;
    }

}

-(void)configureCell:(SearchResultCell*)cell forSearchResult:(SearchResult*)searchResult {

    cell.movieName.text = searchResult.title;
    
    NSString *firstInformationPart = [searchResult.country isEqualToString:@"N/A"] ? @"" : [searchResult.country stringByAppendingString:@" - "];
    cell.countryYear.text = [NSString stringWithFormat:@"%@%@", firstInformationPart, searchResult.year];
    
    if ([cell.countryYear.text length] == 0) {
        
        cell.countryYear.text = @"No Information";
        
    }
    
    if (![searchResult.plot isEqualToString:@"N/A"]) {
        cell.movieDescription.text = searchResult.plot;
    } else {
        cell.movieDescription.text = @"";
    }
    
    if (![searchResult.poster isEqualToString:@"N/A"]) {
        [cell.moviePoster setImageWithURL:[NSURL URLWithString:searchResult.poster]];
    } else {
        [cell.moviePoster setImage:[UIImage imageNamed:@"poster-placeholder"]];
    }

    cell.bookmarkImage.hidden = YES;
    
    if ([self checkMovieInBookmarksWithId:searchResult.movieId]) {
        cell.bookmarkImage.hidden = NO;
    } 
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS8_0)) {
        return [self tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    
    id cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[SearchResultCell class]]) {
        
        SearchResultCell *searchResultCell = (SearchResultCell*)cell;
        
        CGFloat cellHeight = 0;
        
        CGSize idealSize = [searchResultCell.movieDescription sizeThatFits:CGSizeMake(tableView.frame.size.width - 16.0f, MAXFLOAT)];
        
        cellHeight = 12.0f + searchResultCell.movieName.frame.size.height + 9.0f + searchResultCell.countryYear.frame.size.height + 10.0f + searchResultCell.moviePoster.frame.size.height + 10.0f + idealSize.height + 24.0f +8.0f;
        
        return cellHeight;
        
    } else {
        return 44.0;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
    
}


-(BOOL)checkMovieInBookmarksWithId:(NSString*)movieId {
    
    for (int i = 0; i < [[self.fetchedResultsController fetchedObjects] count]; i ++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        Movie *movie = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if ([movieId isEqualToString:movie.movieId]) {
            return YES;
        }
        
    }
    
    return NO;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_search.searchResults count] > 0) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"ShowMovieDetails" sender:_search.searchResults[indexPath.section]];
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowMovieDetails"]) {
        
        MovieDetailController *movieDetailController = segue.destinationViewController;
        movieDetailController.hidesBottomBarWhenPushed = YES;
        
        SearchResult *currentSearchResult = (SearchResult*)sender;
        movieDetailController.title = currentSearchResult.title;
        movieDetailController.movieTitleValue = currentSearchResult.title;
        movieDetailController.movieRatingValue = currentSearchResult.rating;
        movieDetailController.movieDirectorValue = currentSearchResult.director;
        movieDetailController.movieWritersValue = currentSearchResult.writer;
        movieDetailController.movieTypeValue = currentSearchResult.type;
        movieDetailController.movieDescriptionValue = currentSearchResult.plot;
        movieDetailController.poster = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:currentSearchResult.poster]]];;
        movieDetailController.movieId = currentSearchResult.movieId;
        movieDetailController.movieCountryValue = currentSearchResult.country;
        movieDetailController.movieYearValue = currentSearchResult.year;
        movieDetailController.movieGenreValue = currentSearchResult.genre;
        movieDetailController.movieReleasedValue = currentSearchResult.released;
        movieDetailController.movieRuntimeValue = currentSearchResult.runtime;
        
        movieDetailController.managedObjectContext = self.managedObjectContext;
        movieDetailController.fetchedResultsController = self.fetchedResultsController;
        
    }
    
}

#pragma mark - UISearchBarDelegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    if ([self.searchBar.text length] > 0) {
        
        if (!self.logo.hidden) {
            [self hideIMDBLogo];
        }
        
    }
    
    [self performSearch];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
}

- (void)performSearch
{
    
    _search = [[Search alloc] init];
    _search.delegate = self;
    
    [_search performSearchForText:self.searchBar.text];
    
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
    
}

#pragma mark - SearchDelegate

-(void)didReceieveNewSearchResult {

    [self.tableView reloadData];
    
}

@end
