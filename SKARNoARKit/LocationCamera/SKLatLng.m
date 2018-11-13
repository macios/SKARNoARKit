//
//  SKLatLng.m
//  SKARNoARKit
//
//  Created by ac-hu on 2018/9/30.
//

#import "SKLatLng.h"

static double Rc=6378137;
static double Rj=6356725;

@implementation SKLatLng
-(instancetype)initWithCll2D:(CLLocationCoordinate2D)coordinate{
    if (self = [super init]) {
        _loDeg = (int)coordinate.longitude;
        _loMin = (int)((coordinate.longitude - _loDeg) * 60);
        _loSec= (coordinate.longitude - _loDeg - _loMin / 60.) * 3600;
        
        _laDeg = (int)coordinate.latitude;
        _laMin = (int)((coordinate.latitude - _laDeg) * 60);
        _laSec= (coordinate.latitude - _laDeg - _laMin / 60.) * 3600;
        
        _longitude = coordinate.longitude;
        _latitude = coordinate.latitude;
        _radLo = coordinate.longitude * M_PI / 180.;
        _radLa = coordinate.latitude * M_PI / 180.;
        _ec= Rj + (Rc - Rj) * (90. - _latitude) / 90.;
        _ed = _ec * cosf(_radLa);
//        Math.cos(m_RadLa);
    }
    return self;
}

+(double)getAnglePointOne:(CLLocationCoordinate2D)pointOne pointTwp:(CLLocationCoordinate2D)pointTwo{
    
    SKLatLng *A = [[SKLatLng alloc]initWithCll2D:pointOne];
    SKLatLng *B = [[SKLatLng alloc]initWithCll2D:pointTwo];
    
    double dx = (B.radLo - A.radLo) * A.ed;
    double dy = (B.radLa - A.radLa) * A.ec;
    double angle = 0.0;
    
    angle = atan(fabs(dx/dy)) * 180./M_PI;
    double dLo = B.longitude - A.longitude;
    double dLa = B.latitude - A.latitude;
    if(dLo > 0 && dLa <= 0){
        angle = (90.-angle) + 90;
    }else if(dLo <= 0 && dLa < 0){
        angle = angle + 180.;
    }else if(dLo < 0 && dLa >= 0){
        angle = (90. - angle) + 270;
    }
    return angle;
}
@end
