//
//  SearchResult.h
//  IMDBMovies
//
//  Created by Василий Думанов on 06.12.14.
//  Copyright (c) 2014 Vasily Dumanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchResult : NSObject

@property (nonatomic, copy) NSString *movieId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *released;
@property (nonatomic, copy) NSString *runtime;
@property (nonatomic, copy) NSString *genre;
@property (nonatomic, copy) NSString *director;
@property (nonatomic, copy) NSString *writer;
@property (nonatomic, copy) NSString *plot;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *poster;
@property (nonatomic, copy) NSString *rating;
@property (nonatomic, copy) NSString *type;

- (NSComparisonResult)compareName:(SearchResult *)other;

@end
