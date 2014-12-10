//
//  UIImage+ColoredImage.h
//  IMDBMovies
//
//  Created by Василий Думанов on 10.12.14.
//  Copyright (c) 2014 Vasily Dumanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColoredImage)

+ (UIImage*)colorizeImage:(UIImage*)img withColor:(UIColor*)color;

@end
