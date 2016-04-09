//
//  MapAnnotation.h
//  mapMethod
//
//  Created by Timothy Michael Mathews on 2016-03-29.
//  Copyright © 2016 Tim Mathews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <NSCoding>
@property (nonatomic) BOOL isInArea;
@property (nonatomic) BOOL close;
@property (nonatomic, strong) CLCircularRegion *region;
@property (nonatomic, strong) MKPointAnnotation *annotation;
-(id)initWithLocation:(CLLocationCoordinate2D)coord rarity:(BOOL)rarity;
-(MKAnnotationView *)annView;
@end
