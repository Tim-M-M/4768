//
//  UIPeerViewController.h
//  mapMethod
//
//  Created by Timothy Michael Mathews on 2016-04-03.
//  Copyright © 2016 Tim Mathews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <CoreData/CoreData.h>

@interface UIPeerViewController : UIViewController <MCBrowserViewControllerDelegate, MCSessionDelegate, NSFetchedResultsControllerDelegate, /*UIPickerViewDataSource, UIPickerViewDelegate**/ UITableViewDelegate, UITableViewDataSource>

@end
