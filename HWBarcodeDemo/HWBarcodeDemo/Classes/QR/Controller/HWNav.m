//
//  HWNav.m
//  HWBarcodeDemo
//
//  Created by 曹航玮 on 2017/1/21.
//  Copyright © 2017年 曹航玮. All rights reserved.
//

#import "HWNav.h"

@interface HWNav ()

@end

@implementation HWNav

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                 NSFontAttributeName : [UIFont systemFontOfSize:20]};
    self.navigationBar.titleTextAttributes = attributes;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
