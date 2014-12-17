//
//  SecondViewController.m
//  IMDBMovies
//
//  Created by Василий Думанов on 06.12.14.
//  Copyright (c) 2014 Vasily Dumanov. All rights reserved.
//

#import "BookmarksViewController.h"
#import "Movie.h"
#import "SearchResultCell.h"
#import "MovieDetailController.h"
#import "UIImage+ColoredImage.h"

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NoBookmarksCellIdentifier = @"NoBookmarksCell";

@interface BookmarksViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation BookmarksViewController {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.870 alpha:1.000];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [UIColor clearColor];
    
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    cellNib = [UINib nibWithNibName:NoBookmarksCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NoBookmarksCellIdentifier];
    
}



-(void)viewWillAppear:(BOOL)animated {
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource | UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
        self.tableView.scrollEnabled = YES;
        return [[self.fetchedResultsController fetchedObjects] count];
    } else {
        self.tableView.scrollEnabled = NO;
        return 1;
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
        
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier];
        cell.layer.borderColor = [UIColor purpleColor].CGColor;
        cell.layer.borderWidth = 2.0f;
        
        Movie *movie = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.section inSection:0]];
        [self configureCell:cell forBookmark:movie];
        
        cell.layer.cornerRadius = 10;
        cell.layer.masksToBounds = YES;
        
        return cell;
        
    } else {
        
        UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:NoBookmarksCellIdentifier];
        cell.backgroundColor = [UIColor colorWithWhite:0.870 alpha:1.000];
        
        return cell;
        
    }

}

-(void)configureCell:(SearchResultCell*)cell forBookmark:(Movie*)movie {
    
    cell.movieName.text = movie.movieTitle;
    cell.countryYear.text = [NSString stringWithFormat:@"%@ - %@", movie.movieCountry, movie.movieYear];
    
    if (movie.moviePoster != nil) {
        [cell.moviePoster setImage:[UIImage imageWithData:movie.moviePoster]];
    } else {
        [cell.moviePoster setImage:[UIImage imageNamed:@"poster-placeholder"]];
    }
    
    //cell.moviePoster.highlightedImage = [UIImage colorizeImage:cell.moviePoster.image withColor:[UIColor colorWithRed:0.913 green:0.544 blue:1.000 alpha:1.000]];
    
    if (![movie.movieDescription isEqualToString:@"N/A"]) {
        cell.movieDescription.text = movie.movieDescription;
    } else {
        cell.movieDescription.text = @"";
    }
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithRed:0.500 green:0.000 blue:0.500 alpha:0.300];
    cell.selectedBackgroundView = view;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[SearchResultCell class]]) {
        
        SearchResultCell *searchResultCell = (SearchResultCell*)cell;
        
        CGFloat cellHeight = 0;
        
        CGSize idealSize1 = [searchResultCell.movieName sizeThatFits:CGSizeMake(tableView.frame.size.width - 16.0f, MAXFLOAT)];
        CGSize idealSize2 = [searchResultCell.movieDescription sizeThatFits:CGSizeMake(tableView.frame.size.width - 16.0f, MAXFLOAT)];
        
        cellHeight = 12.0f + idealSize1.height + 9.0f + searchResultCell.countryYear.frame.size.height + 10.0f + searchResultCell.moviePoster.frame.size.height + 10.0f + idealSize2.height + ([searchResultCell.movieDescription.text length] > 0 ? 24.0f : 0.0f) +8.0f;
        
        return cellHeight;
        
    } else {
        return 44.0;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"ShowBookmarkDetails" sender:[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.section inSection:0]]];
        
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowBookmarkDetails"]) {

        MovieDetailController *movieDetailController = segue.destinationViewController;
        movieDetailController.hidesBottomBarWhenPushed = YES;
        
        Movie *movie = (Movie*)sender;
        
        movieDetailController.title = movie.movieTitle;
        movieDetailController.movieTitleValue = movie.movieTitle;
        movieDetailController.movieRatingValue = movie.movieRating;
        movieDetailController.movieDirectorValue = movie.movieDirector;
        movieDetailController.movieWritersValue = movie.movieWriters;
        movieDetailController.movieTypeValue = movie.movieType;
        movieDetailController.movieDescriptionValue = movie.movieDescription;
        movieDetailController.poster = [UIImage imageWithData:movie.moviePoster];
        movieDetailController.movieId = movie.movieId;
        movieDetailController.movieCountryValue = movie.movieCountry;
        movieDetailController.movieYearValue = movie.movieYear;
        movieDetailController.movieGenreValue = movie.movieGenre;
        movieDetailController.movieReleasedValue = movie.movieReleased;
        movieDetailController.movieRuntimeValue = movie.movieRuntime;
        
        movieDetailController.managedObjectContext = self.managedObjectContext;
        movieDetailController.fetchedResultsController = self.fetchedResultsController;
        
    }
    
}


@end
