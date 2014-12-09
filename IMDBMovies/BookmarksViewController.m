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

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";
static NSString * const NoBookmarksCellIdentifier = @"NoBookmarksCell";

@interface BookmarksViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@end

@implementation BookmarksViewController {
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.870 alpha:1.000];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    
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
    
    NSLog(@"%lu", (unsigned long)[[self.fetchedResultsController fetchedObjects] count]);
    
    if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
        return [[self.fetchedResultsController fetchedObjects] count];
    } else {
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
        
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier forIndexPath:indexPath];
        cell.layer.borderColor = [UIColor blackColor].CGColor;
        cell.layer.borderWidth = 1.0f;
        
        Movie *movie = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.section inSection:0]];
        [self configureCell:cell forBookmark:movie];
        
        return cell;
        
    } else {
        
        return [tableView dequeueReusableCellWithIdentifier:NoBookmarksCellIdentifier forIndexPath:indexPath];
        
    }

    
}

-(void)configureCell:(SearchResultCell*)cell forBookmark:(Movie*)movie {
    
    cell.movieName.text = movie.movieTitle;
    cell.countryYear.text = [NSString stringWithFormat:@"%@ - %@", movie.movieCountry, movie.movieYear];
    
    if (movie.moviePoster != nil) {
        [cell.moviePoster setImage:[UIImage imageWithData:movie.moviePoster]];
    }
    
    if (![movie.movieDescription isEqualToString:@"N/A"]) {
        cell.movieDescription.text = movie.movieDescription;
    } else {
        cell.movieDescription.text = @"";
    }
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"ShowBookmarkDetails" sender:[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.section inSection:0]]];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowBookmarkDetails"]) {
        
        MovieDetailController *movieDetailController = segue.destinationViewController;
        movieDetailController.hidesBottomBarWhenPushed = YES;
        
        Movie *movie = (Movie*)sender;
        
        movieDetailController.title = movie.movieTitle;
        movieDetailController.movieTitleValue = movie.movieTitle;
        movieDetailController.movieInformationValue = [NSString stringWithFormat:@"%@ - %@ - %@ (%@)", movie.movieRuntime, movie.movieGenre, movie.movieReleased, movie.movieCountry];
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}




@end
