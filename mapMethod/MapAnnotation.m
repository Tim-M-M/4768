//
//  MapAnnotation.m
//  mapMethod
//
//  Created by Timothy Michael Mathews on 2016-03-29.
//  Copyright © 2016 Tim Mathews. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

-(id)initWithLocation:(CLLocationCoordinate2D)coord rarity:(BOOL)rarity{
    self = [super init];
    if (self){
        self.close = rarity;
        self.isInArea = NO;
        self.annotation.coordinate = coord;
        self.annotation.title = @"Title";
        self.region = [[CLCircularRegion alloc] initWithCenter:coord radius:100 identifier:@"Region"];
    }
    return self;
}

-(MKAnnotationView *)annView {
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:self.annotation reuseIdentifier:@"MapAnnotation"];
    view.enabled = YES;
    return view;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:@(self.isInArea) forKey:@"isInArea"];
    [aCoder encodeObject:@(self.close) forKey:@"close"];
    [aCoder encodeObject:self.region forKey:@"region"];
    [aCoder encodeObject:self.annotation.title forKey:@"annotationTitle"];
    [aCoder encodeDouble:self.annotation.coordinate.latitude forKey:@"annotationLat"];
    [aCoder encodeDouble:self.annotation.coordinate.longitude forKey:@"annotationLong"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    self.isInArea = [aDecoder decodeObjectForKey:@"isInArea"];
    self.close = [aDecoder decodeObjectForKey:@"close"];
    self.region = [aDecoder decodeObjectForKey:@"region"];
    self.annotation = [[MKPointAnnotation alloc] init];
    self.annotation.coordinate = CLLocationCoordinate2DMake([aDecoder decodeDoubleForKey:@"annotationLat"], [aDecoder decodeDoubleForKey:@"annotationLong"]);
    self.annotation.title = [aDecoder decodeObjectForKey:@"annotationTitle"];
    return self;
}

@end
