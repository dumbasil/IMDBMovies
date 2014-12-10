//
//  Search.m
//  IMDBMovies
//
//  Created by Василий Думанов on 06.12.14.
//  Copyright (c) 2014 Vasily Dumanov. All rights reserved.
//

#import "Search.h"
#import "SearchResult.h"
#import <AFNetworking/AFNetworking.h>

static NSOperationQueue *queue = nil;

@interface Search()

@property (nonatomic, readwrite, strong) NSMutableArray *searchResults;

@end

@implementation Search

+(void)initialize {
    
    if (self == [Search class]) {
        queue = [[NSOperationQueue alloc] init];
    }
    
}

- (NSURL *)urlWithSearchText:(NSString *)searchText
{
    
    NSString *escapedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://www.omdbapi.com/?s=%@&r=json", escapedSearchText];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
    
}

- (NSURL *)urlWithMovieId:(NSString *)movieId
{
    
    NSString *urlString = [NSString stringWithFormat:@"http://www.omdbapi.com/?i=%@&r=json&plot=full", movieId];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
    
}

-(void)parseSearchResults:(NSDictionary *)searchResultsDictionary {
 
    NSArray *array = searchResultsDictionary[@"Search"];
    if (array == nil) {
        [self.delegate didReceieveNewSearchResult];
        return;
    }
    
    for (NSDictionary *resultDict in array) {
        
        NSString *movieId = resultDict[@"imdbID"];
        [self performSearchForMovieId:movieId];
        
    }
    
}

- (void)parseDictionary:(NSDictionary *)dictionary {
    
    SearchResult *searchResult = [[SearchResult alloc] init];
    
    if ([dictionary[@"Type"]  isEqual: @"movie"] || [dictionary[@"Type"]  isEqual: @"series"] || [dictionary[@"Type"]  isEqual: @"episode"]) {
        searchResult.movieId = dictionary[@"imdbID"];
        searchResult.title = dictionary[@"Title"];
        searchResult.year = dictionary[@"Year"];
        searchResult.released = dictionary[@"Released"];
        searchResult.runtime = dictionary[@"Runtime"];
        searchResult.genre = dictionary[@"Genre"];
        searchResult.director = dictionary[@"Director"];
        searchResult.writer = dictionary[@"Writer"];
        searchResult.plot = dictionary[@"Plot"];
        searchResult.language = dictionary[@"Language"];
        searchResult.country = dictionary[@"Country"];
        searchResult.poster = dictionary[@"Poster"];
        searchResult.rating = dictionary[@"imdbRating"];
        searchResult.type = dictionary[@"Type"];
        
        [self.searchResults addObject:searchResult];
        [self.delegate didReceieveNewSearchResult];
        
    }
    
}

-(void)performSearchForText:(NSString *)text {
    
    if ([text length] > 0) {
        [queue cancelAllOperations];
        
        self.isLoading = YES;
        
        self.searchResults = [NSMutableArray arrayWithCapacity:10];
        
        NSURL *url = [self urlWithSearchText:text];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"First request succeeded!");
            [self parseSearchResults:responseObject];
            
            self.isLoading = NO;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (!operation.isCancelled) {
                self.isLoading = NO;
            } else {
                
                self.isLoading = NO;
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                                message:@"Either your device is not connected to the Internet or IMDb server is not responding"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [self.delegate didReceieveNewSearchResult];
            }
        
        }];
        
        [queue addOperation:operation];
    }
    
}

-(void)performSearchForMovieId:(NSString *)movieId {
    
    NSURL *url = [self urlWithMovieId:movieId];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        [self parseDictionary:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        self.isLoading = NO;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                        message:@"Either your device is not connected to the Internet or IMDb server is not responding"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.delegate didReceieveNewSearchResult];
        
    }];
    
    [queue addOperation:operation];
    
}

@end
