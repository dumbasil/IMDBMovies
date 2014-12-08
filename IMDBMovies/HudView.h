//
//  HudView.h
//  IMDBMovies
//
//  Created by Василий Думанов on 08.12.14.
//  Copyright (c) 2014 Vasily Dumanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudView : UIView

@property (nonatomic, strong) NSString *text;

+(instancetype)hudInView:(UIView*)view;

@end
