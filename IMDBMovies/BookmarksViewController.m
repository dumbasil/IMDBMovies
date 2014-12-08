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
    
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    cellNib = [UINib nibWithNibName:NoBookmarksCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NoBookmarksCellIdentifier];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource | UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([_bookmarks count] > 0) {
        return [_bookmarks count];
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
    
    if ([_bookmarks count] > 0) {
        
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier forIndexPath:indexPath];
        cell.layer.borderColor = [UIColor blackColor].CGColor;
        cell.layer.borderWidth = 1.0f;
        
        Movie *movie = _bookmarks[indexPath.section];
        [self configureCell:cell forBookmark:movie];
        
        return cell;
        
    } else {
        
        return [tableView dequeueReusableCellWithIdentifier:NoBookmarksCellIdentifier forIndexPath:indexPath];
        
    }

    
}

-(void)configureCell:(SearchResultCell*)cell forBookmark:(Movie*)movie {
    
    cell.movieName.text = movie.movieTitle;
    cell.countryYear.text = [NSString stringWithFormat:@"%@ - %@", movie.movieCountry, movie.movieYear];
    
    if (![movie.movieDescription isEqualToString:@"N/A"]) {
        cell.movieDescription.text = movie.movieDescription;
    } else {
        cell.movieDescription.text = @"";
    }
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self performSegueWithIdentifier:@"ShowMovieDetails" sender:_search.searchResults[indexPath.section]];
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}




@end
