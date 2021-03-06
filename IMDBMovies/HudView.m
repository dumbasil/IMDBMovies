//
//  HudView.m
//  IMDBMovies
//
//  Created by Василий Думанов on 08.12.14.
//  Copyright (c) 2014 Vasily Dumanov. All rights reserved.
//

#import "HudView.h"

#import "HudView.h"

static const UIView *parentView;

@implementation HudView {
    
    
}

+(instancetype)hudInView:(UIView *)view{
    
    HudView *hudView = [[HudView alloc] initWithFrame:view.bounds];
    hudView.opaque = NO;
    [view addSubview:hudView];
    view.userInteractionEnabled = NO;
    
    parentView = view;
    
    [hudView showAndHide];
    
    return hudView;
    
}

-(void)drawRect:(CGRect)rect {
    
    const CGFloat boxWidth = 96.0f;
    const CGFloat boxHeight = 96.0f;
    
    CGRect boxRect = CGRectMake(roundf((self.bounds.size.width - boxWidth)/2.0f), roundf((self.bounds.size.height - boxHeight)/2.0f), boxWidth, boxHeight);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:10.0f];
    [[UIColor colorWithRed:0.500 green:0.000 blue:0.500 alpha:0.620] setFill];
    [roundedRect fill];
    
    UIImage *image = [UIImage imageNamed:@"Checkmark"];
    
    CGPoint imagePoint = CGPointMake(self.center.x - roundf(image.size.width/2.0), self.center.y - roundf(image.size.height/2.0) - boxHeight/8.0f);
    [image drawAtPoint:imagePoint];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont systemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName : [UIColor whiteColor]
                                 };
    
    CGSize textSize = [self.text sizeWithAttributes:attributes];
    CGPoint textPoint = CGPointMake(self.center.x - roundf(textSize.width/2.0f), self.center.y - roundf(textSize.height/2.0f) + boxHeight/4.0f);
    
    [self.text drawAtPoint:textPoint withAttributes:attributes];
    
}

-(void)showAndHide{
    
    self.alpha = 0.0f;
    self.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        
    [UIView animateWithDuration:0.3 animations:^{
            
        self.alpha = 1.0f;
        self.transform = CGAffineTransformIdentity;
            
    } completion:^(BOOL finished) {
                
        [UIView animateWithDuration:0.3 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    
                self.alpha = 0.0f;
                self.transform = CGAffineTransformIdentity;
                    
            } completion:^(BOOL finished) {
                parentView.userInteractionEnabled = YES;
                [self removeFromSuperview];
            }];
            
    }];
    
}

@end

