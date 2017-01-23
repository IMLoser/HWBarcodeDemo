//
//  HWBarcodeController.m
//  HWBarcodeDemo
//
//  Created by 曹航玮 on 2017/1/21.
//  Copyright © 2017年 曹航玮. All rights reserved.
//

#import "HWBarcodeController.h"

@interface HWBarcodeController ()

@end

@implementation HWBarcodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)barcodeClick:(UIButton *)sender {
    
    UIStoryboard * qrStoryboard = [UIStoryboard storyboardWithName:@"QR" bundle:nil];
    UIViewController * qrVC = [qrStoryboard instantiateInitialViewController];
    [self presentViewController:qrVC animated:YES completion:nil];
}

@end
