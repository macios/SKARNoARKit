//
//  SKAR3DVC.m
//  SKARNoARKit
//
//  Created by ac-hu on 2018/11/13.
//  Copyright © 2018年 SK-HU. All rights reserved.
//

#import "SKAR3DVC.h"
#import "SKCameraView.h"

@interface SKAR3DVC ()

@end

@implementation SKAR3DVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [SKCameraView share].frame = self.view.bounds;
    [self.view addSubview:[SKCameraView share]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
