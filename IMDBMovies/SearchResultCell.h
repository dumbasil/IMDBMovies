//
//  SearchCell.h
//  IMDBMovies
//
//  Created by Василий Думанов on 06.12.14.
//  Copyright (c) 2014 Vasily Dumanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *movieName;
@property (nonatomic, weak) IBOutlet UILabel *countryYear;
@property (nonatomic, weak) IBOutlet UIImageView *moviePoster;
@property (nonatomic, weak) IBOutlet UILabel *movieDescription;
@property (nonatomic, weak) IBOutlet UIImageView *bookmarkImage;

@property (nonatomic, assign) UIImage* unscaledImage;

@end
