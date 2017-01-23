//
//  QRAnimationView.h
//  HWBarcodeDemo
//
//  Created by 曹航玮 on 2017/1/21.
//  Copyright © 2017年 曹航玮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRAnimationView : UIView

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightCons;

- (void)beginAnimation;

- (void)stopAnimation;

@end
