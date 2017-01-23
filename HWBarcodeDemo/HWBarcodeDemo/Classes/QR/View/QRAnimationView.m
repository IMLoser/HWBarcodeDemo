//
//  QRAnimationView.m
//  HWBarcodeDemo
//
//  Created by 曹航玮 on 2017/1/21.
//  Copyright © 2017年 曹航玮. All rights reserved.
//

#import "QRAnimationView.h"

@interface QRAnimationView ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *cons;

@end

@implementation QRAnimationView

- (void)beginAnimation {
    
    _cons.constant = -_heightCons.constant;
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:2.0 animations:^{
        
         _cons.constant = _heightCons.constant;
        
        [UIView setAnimationRepeatCount:MAXFLOAT];
        
        [self layoutIfNeeded];
        
    }];
}

- (void)stopAnimation
{
    [self.layer removeAllAnimations];
}

@end
