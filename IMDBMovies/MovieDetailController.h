//
//  MovieDetailController.h
//  IMDBMovies
//
//  Created by Василий Думанов on 07.12.14.
//  Copyright (c) 2014 Vasily Dumanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MovieDetailController : UIViewController

@property (nonatomic, strong) NSString *movieTitleValue;
@property (nonatomic, strong) NSString *movieInformationValue;
@property (nonatomic, strong) NSString *movieRatingValue;
@property (nonatomic, strong) NSString *movieDirectorValue;
@property (nonatomic, strong) NSString *movieWritersValue;
@property (nonatomic, strong) NSString *movieTypeValue;
@property (nonatomic, strong) NSString *movieDescriptionValue;
@property (nonatomic, strong) NSString *posterUrl;
@property (nonatomic, strong) NSString *movieId;

@property (nonatomic, strong) NSString *movieCountryValue;
@property (nonatomic, strong) NSString *movieYearValue;
@property (nonatomic, strong) NSString *movieGenreValue;
@property (nonatomic, strong) NSString *movieReleasedValue;
@property (nonatomic, strong) NSString *movieRuntimeValue;

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UILabel *movieTitle;
@property (nonatomic, weak) IBOutlet UILabel *movieInformation;
@property (nonatomic, weak) IBOutlet UILabel *movieRating;
@property (nonatomic, weak) IBOutlet UILabel *movieDirector;
@property (nonatomic, weak) IBOutlet UILabel *movieWriters;
@property (nonatomic, weak) IBOutlet UILabel *movieType;
@property (nonatomic, weak) IBOutlet UILabel *movieDescription;
@property (nonatomic, weak) IBOutlet UIImageView *moviePoster;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
