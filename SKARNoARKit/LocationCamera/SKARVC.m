//
//  SKARVC.m
//  SKARNoARKit
//
//  Created by ac-hu on 2018/9/30.
//  Copyright © 2018年 SK-HU. All rights reserved.
//

#import "SKARVC.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "SKLatLng.h"
#import "SKLocationView.h"

#define TimeUpdateInterval (1/60.)

@interface SKARVC()<CLLocationManagerDelegate,UIAccelerometerDelegate>

@property(nonatomic,strong)NSMutableArray *locationArr;
@property(nonatomic,strong)CMMotionManager *motMgr;//加速器
@property(nonatomic,strong)CLLocationManager *locManager;
@property(nonatomic,assign)float acceZ;
@property(nonatomic,assign)float locHead;
@property(nonatomic,assign)float angleX;
@property(nonatomic,assign)float angleY;
@property(nonatomic,assign)float offsetX;

@end

@implementation SKARVC

- (void)viewDidLoad
{
    _locationArr = @[].mutableCopy;
    [super viewDidLoad];
    [self loadData];
    [self startgps];
    _motMgr = [CMMotionManager new];
    [self CMMotionStart];
}

-(void)CMMotionStop{
    if (_motMgr) {
        [_motMgr stopAccelerometerUpdates];
    }
}

-(void)CMMotionStart{
    if (_motMgr) {
        if (_motMgr.gyroAvailable == YES) {
            _motMgr.accelerometerUpdateInterval = TimeUpdateInterval;
            _motMgr.gyroUpdateInterval = TimeUpdateInterval;
            [_motMgr startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                if (!error) {
                    [self outputAccelertionData:accelerometerData.acceleration];
                }else{
                    NSLog(@"%@", error);
                }
            }];
        }
    }
}

- (void)outputAccelertionData:(CMAcceleration)acceleration{
    _acceZ = acceleration.z;
    [self changeAngle];
}

-(void)startgps{
    _locManager = [[CLLocationManager alloc] init];
    _locManager.delegate = self;
    _locManager.distanceFilter = 1000.0f;
    _locManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locManager startUpdatingHeading];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    _locHead = newHeading.magneticHeading;
}
-(void)changeAngle{
    static float __index = 0;
    
    for (SKLocationView *view in _locationArr) {
        float mikustart = view.model.angle;
        
        float scale = view.model.scale;//根据AR物体模拟的距离来定
        if (_locHead < 180) {
            _angleX = -_locHead + mikustart;
        }else{
            _angleX = 360-_locHead + mikustart;
        }
        if (_angleX < 180) {
            _offsetX = _angleX * scale;
        }else{
            _offsetX = (_angleX - 360) * scale;
        }
        
        if (fabsf(_acceZ - __index) > 0.05) {
            __index = _acceZ;
        }else{
            _acceZ = __index;
            _angleY = 240 * _acceZ * 2;//“2”这个修正值也是根据AR物体模拟的距离来定
            typeof(self) __weak weakSelf = self;
            NSLog(@"%f %f",_acceZ,_angleX);
            [UIView animateWithDuration:0.1 animations:^{
                view.center = CGPointMake(weakSelf.offsetX + view.bounds.size.width / 2., weakSelf.angleY + weakSelf.view.bounds.size.height/2.);
            }];
        }
    }
}

-(void)loadData{
    NSArray *coordinateArr = @[@"104.069254,30.568088",@"104.064941,30.570527",@"104.061851,30.571192",@"104.060735,30.572319",@"104.057538,30.571395",@"104.057431,30.56539",@"104.063053,30.563672",@"104.072644,30.56552"];
    NSArray *nameArr = @[@"锦城广场",@"环球中心E5",@"环球中心N3",@"孵化园9区",@"林风小区",@"锦城湖",@"桂溪生态园",@"濯锦立交"];
    for (int i = 0; i < coordinateArr.count; i ++) {
        SKLocationView *view = [[SKLocationView alloc]init];
        view.bounds = CGRectMake(0, 0, 60, 40);
        [self.view addSubview:view];
        UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
        [view addSubview:label];
        label.text = nameArr[i];
        label.adjustsFontSizeToFitWidth = YES;
        SKLocationModel *model = [SKLocationModel new];
        model.scale = 10;
        NSArray *arr= [coordinateArr[i] componentsSeparatedByString:@","];
        model.angle = [SKLatLng getAnglePointOne:CLLocationCoordinate2DMake(30.571576198481718, 104.05918722502075) pointTwp:CLLocationCoordinate2DMake([arr.lastObject floatValue],[arr.firstObject floatValue])];
        view.model = model;
        [_locationArr addObject:view];
    }
}

@end
