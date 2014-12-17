//
//  MovieDetailController.m
//  IMDBMovies
//
//  Created by Василий Думанов on 07.12.14.
//  Copyright (c) 2014 Vasily Dumanov. All rights reserved.
//

#import "MovieDetailController.h"
#import "Movie.h"
#import "HudView.h"

#import "SearchViewController.h"
#import "BookmarksViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import <CoreData/CoreData.h>

@interface MovieDetailController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UILabel *movieTitle;
@property (nonatomic, weak) IBOutlet UILabel *movieInformation;
@property (nonatomic, weak) IBOutlet UILabel *movieRating;
@property (nonatomic, weak) IBOutlet UILabel *movieDirector;
@property (nonatomic, weak) IBOutlet UILabel *movieWriters;
@property (nonatomic, weak) IBOutlet UILabel *movieType;
@property (nonatomic, weak) IBOutlet UILabel *movieDescription;
@property (nonatomic, weak) IBOutlet UIImageView *moviePoster;
@property (nonatomic, weak) IBOutlet UIImageView *bookmarkImage;

@end

@implementation MovieDetailController {
    
    UIActionSheet *_actionSheet;
    NSString *_addOrDelete;
    NSIndexPath *_indexPathForDeleting;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(performAction:)];
    self.navigationItem.rightBarButtonItem = shareButton;
    [self fillMovieInformationFields];
    
    if (![self checkMovieInBookmarksWithId:self.movieId]) {
        self.bookmarkImage.hidden = YES;
    }
    
}

-(IBAction)performAction:(id)sender {
    
    if ([self checkMovieInBookmarksWithId:self.movieId]) {
        _addOrDelete = @"Delete bookmark";
    } else {
        _addOrDelete = @"Add bookmark";
    }
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Twitter Share", @"Facebook Share", @"Email share", _addOrDelete, nil];
    
    SEL selector = NSSelectorFromString(@"_alertController");
    if ([_actionSheet respondsToSelector:selector])
    {
        UIAlertController *alertController = [_actionSheet valueForKey:@"_alertController"];
        if ([alertController isKindOfClass:[UIAlertController class]])
        {
            alertController.view.tintColor = [UIColor purpleColor];
        }
    }
    
    [_actionSheet showInView:self.view];
    
}

-(BOOL)checkMovieInBookmarksWithId:(NSString*)movieId {
    
    for (int i = 0; i < [[self.fetchedResultsController fetchedObjects] count]; i ++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        Movie *movie = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if ([movieId isEqualToString:movie.movieId]) {
            _indexPathForDeleting = indexPath;
            return YES;
        }
        
    }
    
    return NO;
    
}

-(void)fillMovieInformationFields {
    
    self.movieTitle.text = self.movieTitleValue;
    
    NSString *firstInformationPart = [self.movieRuntimeValue isEqualToString:@"N/A"] ? @"" : [self.movieRuntimeValue stringByAppendingString:@" - "];
    NSString *secondInformationPart = [self.movieGenreValue isEqualToString:@"N/A"] ? @"" : [self.movieGenreValue stringByAppendingString:@" - "];
    NSString *thirdInformationPart = [self.movieReleasedValue isEqualToString:@"N/A"] ? @"" : [self.movieReleasedValue stringByAppendingString:@" "];
    NSString *fourthInformationPart = [self.movieCountryValue isEqualToString:@"N/A"] ? @"" : [NSString stringWithFormat:@"(%@)", self.movieCountryValue];
    
    self.movieInformation.text = [NSString stringWithFormat:@"%@%@%@%@", firstInformationPart, secondInformationPart, thirdInformationPart, fourthInformationPart];
    if ([self.movieInformation.text length] == 0) {
        self.movieInformation.text = @"No Information";
    }
    self.movieRating.text = [self.movieRatingValue isEqualToString:@"N/A"] ? @"unknown" : [self.movieRatingValue stringByAppendingString:@"/10"];
    self.movieDirector.text = [self.movieDirectorValue isEqualToString:@"N/A"] ? @"unknown" : self.movieDirectorValue;
    self.movieWriters.text = [self.movieWritersValue isEqualToString:@"N/A"] ? @"unknown" : self.movieWritersValue;
    self.movieType.text = [self.movieTypeValue isEqualToString:@"N/A"] ? @"unknown" : self.movieTypeValue;
    self.movieDescription.text = [self.movieDescriptionValue isEqualToString:@"N/A"] ? @"No description" : self.movieDescriptionValue;
    
    if (!self.poster) {
        
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            
            self.poster = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.posterUrlString]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self fillImageViewWithImage];
                
            });
            
        });
        
    } else {
        [self fillImageViewWithImage];
    }

}

-(void)fillImageViewWithImage {
    
    CGFloat imageWidth = self.poster.size.width;
    CGFloat imageHeight = self.poster.size.height;
    
    CGFloat ratio = self.moviePoster.frame.size.width / imageWidth;
    CGFloat newImageViewHeight = (int)(imageHeight * ratio);
    
    CGRect newImageRect = self.moviePoster.frame;
    newImageRect.size.height = newImageViewHeight;
    self.moviePoster.frame = newImageRect;
    
    [self.moviePoster setImage:self.poster];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *linkToMovie = [NSString stringWithFormat:@"http://www.imdb.com/title/%@/", self.movieId];
    NSString *shareText = [NSString stringWithFormat:@"Have you watched '%@' already? If not, you better do it now: %@", self.movieTitle.text, linkToMovie];
    
    if (buttonIndex == 0) {
        
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweet setInitialText:shareText];
            [tweet setCompletionHandler:^(SLComposeViewControllerResult result)
             {
                 if (result == SLComposeViewControllerResultCancelled)
                 {
                     NSLog(@"The user cancelled.");
                 }
                 else if (result == SLComposeViewControllerResultDone)
                 {
                     NSLog(@"The user sent the tweet");
                 }
             }];
            [self presentViewController:tweet animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter"
                                                            message:@"Twitter integration is not available.  A Twitter account must be set up on your device."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    } else if (buttonIndex == 1) {
        
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            SLComposeViewController *tweet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [tweet setInitialText:shareText];
            [tweet setCompletionHandler:^(SLComposeViewControllerResult result)
             {
                 if (result == SLComposeViewControllerResultCancelled)
                 {
                     NSLog(@"The user cancelled.");
                 }
                 else if (result == SLComposeViewControllerResultDone)
                 {
                     NSLog(@"The user posted to Facebook");
                 }
             }];
            [self presentViewController:tweet animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook"
                                                            message:@"Facebook integration is not available.  A Facebook account must be set up on your device."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    } else if (buttonIndex == 2) {
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        
        if (controller != nil && [MFMailComposeViewController canSendMail]) {
            controller.mailComposeDelegate = self;
            controller.modalPresentationStyle = UIModalPresentationFormSheet;
            [controller setMessageBody:shareText isHTML:NO];
            [controller setToRecipients:@[@"your@email-address-here.com"]];
            
            [self presentViewController:controller animated:YES completion:nil];
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail"
                                                            message:@"Mail service is not available on your device."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

        }
        
    } else if (buttonIndex == 3) {
        
        if ([_addOrDelete isEqualToString:@"Add bookmark"]) {
            [self saveBookmarkInDatabase];
        } else if ([_addOrDelete isEqualToString:@"Delete bookmark"]) {
            [self deleteBookmarkFromDatabase];
        }
        
    }
    
}

-(void)saveBookmarkInDatabase {
    
    Movie *movie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:self.managedObjectContext];
    
    movie.movieId = self.movieId;
    movie.movieTitle = self.movieTitleValue;
    movie.movieCountry = self.movieCountryValue;
    movie.movieDescription = self.movieDescriptionValue;
    movie.movieDirector = self.movieDirectorValue;
    movie.movieGenre = self.movieGenreValue;
    movie.movieRating = self.movieRatingValue;
    movie.movieReleased = self.movieReleasedValue;
    movie.movieRuntime = self.movieRuntimeValue;
    movie.movieType = self.movieTypeValue;
    movie.movieWriters = self.movieWritersValue;
    movie.movieYear = self.movieYearValue;
    
    NSData *imageData = UIImageJPEGRepresentation(self.poster, 100.0);
    movie.moviePoster = imageData;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    } else {
        HudView *hudView = [HudView hudInView:self.navigationController.view];
        hudView.text = @"Added!";
        
        self.bookmarkImage.hidden = NO;
    }
    
}

-(void)deleteBookmarkFromDatabase {
    
    Movie *movie = [self.fetchedResultsController objectAtIndexPath:_indexPathForDeleting];
    [self.managedObjectContext deleteObject:movie];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    } else {
        HudView *hudView = [HudView hudInView:self.navigationController.view];
        hudView.text = @"Deleted!";
        
        self.bookmarkImage.hidden = YES;
    }

    
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UIActionSheetDelegate

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            //button.titleLabel.textColor = [UIColor purpleColor];
            [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor purpleColor] forState:UIControlStateSelected];
            [button setTitleColor:[UIColor purpleColor] forState:UIControlStateHighlighted];
        }
    }
}

@end
