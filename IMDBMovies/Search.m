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
        NSLog(@"Expected 'Search' array");
        [self.delegate didReceieveNewSearchResult];
        return;
    }
    
    for (NSDictionary *resultDict in array) {
        
        BOOL final = NO;
        
        if (resultDict == [array lastObject]) {
            final = YES;
        }
        
        NSString *movieId = resultDict[@"imdbID"];
        [self performSearchForMovieId:movieId final:final];
        
    }
    
}

- (void)parseDictionary:(NSDictionary *)dictionary  final:(BOOL)isFinal{
    
    NSLog(@"%@", dictionary);
    
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
        
        //if (isFinal) {
            [self.delegate didReceieveNewSearchResult];
        //}
        
    }
    
}

-(void)performSearchForText:(NSString *)text completion:(SearchBlock)block {
    
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
            block(YES);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"First request failed %@", error);
            if (!operation.isCancelled) {
                self.isLoading = NO;
                block(NO);
            }
            
        }];
        
        [queue addOperation:operation];
    }
    
}

-(void)performSearchForMovieId:(NSString *)movieId final:(BOOL)isFinal {
    
    NSURL *url = [self urlWithMovieId:movieId];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Second request succeeded!");
        [self parseDictionary:responseObject final:isFinal];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Second request failed: %@", error);
        
    }];
    
    [queue addOperation:operation];
    
}

@end
