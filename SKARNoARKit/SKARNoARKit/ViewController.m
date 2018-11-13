//
//  ViewController.m
//  SKARNoARKit
//
//  Created by ac-hu on 2018/11/13.
//  Copyright © 2018年 SK-HU. All rights reserved.
//

#import "ViewController.h"
#import "SKARVC.h"
#import "SKAR3DVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)locBtnClick:(id)sender {
    [self.navigationController pushViewController:[SKARVC new] animated:YES];
}
- (IBAction)DBtnClick:(id)sender {
    [self.navigationController pushViewController:[SKAR3DVC new] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
