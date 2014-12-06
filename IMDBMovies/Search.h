//
//  Search.h
//  IMDBMovies
//
//  Created by Василий Думанов on 06.12.14.
//  Copyright (c) 2014 Vasily Dumanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Search : NSObject

@property (nonatomic, readonly, strong) NSMutableArray *searchResults;

-(void)performSearchForText:(NSString*)text;

@end
