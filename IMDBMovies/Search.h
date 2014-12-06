//
//  Search.h
//  IMDBMovies
//
//  Created by Василий Думанов on 06.12.14.
//  Copyright (c) 2014 Vasily Dumanov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SearchBlock)(BOOL success);

@protocol SearchDelegate <NSObject>

-(void)didReceieveNewSearchResult;

@end

@interface Search : NSObject

@property (nonatomic, strong) id delegate;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, readonly, strong) NSMutableArray *searchResults;

-(void)performSearchForText:(NSString*)text completion:(SearchBlock)block;

@end
