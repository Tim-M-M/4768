//
//  ViewController.h
//  mapMethod
//
//  Created by Timothy Michael Mathews on 2016-03-28.
//  Copyright © 2016 Tim Mathews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CollectionItem.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

-(void)incrementCollectionItemWithName:(NSString *)mName positive:(BOOL)inc;

@property (strong, nonatomic) NSArray<CollectionItem *> *collection;

@end

