//
//  SKLatLng.h
//  SKARNoARKit
//
//  Created by ac-hu on 2018/9/30.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SKLatLng : NSObject
@property(nonatomic,assign)double loDeg;
@property(nonatomic,assign)double loMin;
@property(nonatomic,assign)double loSec;
@property(nonatomic,assign)double laDeg;
@property(nonatomic,assign)double laMin;
@property(nonatomic,assign)double laSec;
@property(nonatomic,assign)double longitude;
@property(nonatomic,assign)double latitude;
@property(nonatomic,assign)double radLo;
@property(nonatomic,assign)double radLa;
@property(nonatomic,assign)double ec;
@property(nonatomic,assign)double ed;

-(instancetype)initWithCll2D:(CLLocationCoordinate2D)coordinate;
+(double)getAnglePointOne:(CLLocationCoordinate2D)pointOne pointTwp:(CLLocationCoordinate2D)pointTwo;
@end
