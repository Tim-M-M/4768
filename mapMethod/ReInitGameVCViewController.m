//
//  ReInitGameVCViewController.m
//  mapMethod
//
//  Created by Timothy Michael Mathews on 2016-04-09.
//  Copyright © 2016 Tim Mathews. All rights reserved.
//

#import "ReInitGameVCViewController.h"

@interface ReInitGameVCViewController ()

@end

@implementation ReInitGameVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"View did load");
    self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
