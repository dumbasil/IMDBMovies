//
//  Movie.h
//  IMDBMovies
//
//  Created by Василий Думанов on 08.12.14.
//  Copyright (c) 2014 Vasily Dumanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Movie : NSManagedObject

@property (nonatomic, retain) NSString * movieId;
@property (nonatomic, retain) NSString * movieTitle;
@property (nonatomic, retain) NSString * movieYear;
@property (nonatomic, retain) NSString * movieReleased;
@property (nonatomic, retain) NSString * movieRuntime;
@property (nonatomic, retain) NSString * movieGenre;
@property (nonatomic, retain) NSString * movieDirector;
@property (nonatomic, retain) NSString * movieWriters;
@property (nonatomic, retain) NSString * movieDescription;
@property (nonatomic, retain) NSString * movieCountry;
@property (nonatomic, retain) NSData * moviePoster;
@property (nonatomic, retain) NSString * movieRating;
@property (nonatomic, retain) NSString * movieType;

@end
