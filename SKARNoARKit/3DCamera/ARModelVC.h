//
//  MyInfoSetPhoneVC.h
//  ProjectPublic
//
//  Created by ac-hu on 2018/8/6.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface ARModelVC : GLKViewController

@property (nonatomic,assign)GLfloat earthRotationAngleDegrees;//水平方向旋转
@property (nonatomic,assign)GLfloat sceneEarthAxialTiltDeg;//垂直方向旋转
//@property (nonatomic,assign)GLfloat sceneZAngle;//垂直方向旋转
@property (nonatomic,assign)CGRect bounds;

@property (nonatomic,assign)int modelType;//垂直方向旋转

-(void)changeModel;

-(void)changeModelOne;

-(void)changeModelTwo;

-(void)addTimer;

-(void)removeTimer;

@end
