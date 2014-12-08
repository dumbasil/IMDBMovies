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
#import <CoreData/CoreData.h>

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
    
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
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
        
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier forIndexPath:indexPath];
        cell.layer.borderColor = [UIColor blackColor].CGColor;
        cell.layer.borderWidth = 1.0f;
        
        SearchResult *searchResult = _search.searchResults[indexPath.section];
        [self configureCell:cell forSearchResult:searchResult];
        
        return cell;
    }

}

-(void)configureCell:(SearchResultCell*)cell forSearchResult:(SearchResult*)searchResult {

    cell.movieName.text = searchResult.title;
    cell.countryYear.text = [NSString stringWithFormat:@"%@ - %@", searchResult.country, searchResult.year];
    
    if (![searchResult.plot isEqualToString:@"N/A"]) {
        cell.movieDescription.text = searchResult.plot;
    } else {
        cell.movieDescription.text = @"";
    }
    
    
    [cell.moviePoster setImageWithURL:[NSURL URLWithString:searchResult.poster]];
    
}



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
        
        SearchResult *currentSearchResult = (SearchResult*)sender;
        movieDetailController.title = currentSearchResult.title;
        movieDetailController.movieTitleValue = currentSearchResult.title;
        movieDetailController.movieInformationValue = [NSString stringWithFormat:@"%@ - %@ - %@ (%@)", currentSearchResult.runtime, currentSearchResult.genre, currentSearchResult.released, currentSearchResult.country];
        movieDetailController.movieRatingValue = [currentSearchResult.rating stringByAppendingString:@"/10"];
        movieDetailController.movieDirectorValue = currentSearchResult.director;
        movieDetailController.movieWritersValue = currentSearchResult.writer;
        movieDetailController.movieTypeValue = currentSearchResult.type;
        movieDetailController.movieDescriptionValue = currentSearchResult.plot;
        movieDetailController.posterUrl = currentSearchResult.poster;
        movieDetailController.movieId = currentSearchResult.movieId;
        movieDetailController.movieCountryValue = currentSearchResult.country;
        movieDetailController.movieYearValue = currentSearchResult.year;
        movieDetailController.movieGenreValue = currentSearchResult.genre;
        movieDetailController.movieReleasedValue = currentSearchResult.released;
        movieDetailController.movieRuntimeValue = currentSearchResult.runtime;
        
        movieDetailController.managedObjectContext = self.managedObjectContext;
        
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
