//
//  ConfirmationVC.m
//  mapMethod
//
//  Created by Timothy Michael Mathews on 2016-04-09.
//  Copyright © 2016 Tim Mathews. All rights reserved.
//

#import "ConfirmationVC.h"
#import "Creature.h"
#import "CollectionItem.h"

@interface ConfirmationVC ()
@property (strong, nonatomic) NSArray<CollectionItem *> *collection;
@end

@implementation ConfirmationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"View did load");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)yesPressed:(id)sender {
    Creature *cryBaby = [[Creature alloc] init];
    cryBaby.name = @"Crybaby";
    CollectionItem *i1 = [[CollectionItem alloc] initWithCreature:cryBaby count:0];
    Creature *whitey = [[Creature alloc] init];
    whitey.name = @"Whitey";
    CollectionItem *i2 = [[CollectionItem alloc] initWithCreature:whitey count:0];
    Creature *pink = [[Creature alloc] init];
    pink.name = @"Pink";
    CollectionItem *i3 = [[CollectionItem alloc] initWithCreature:pink count:0];
    Creature *smug = [[Creature alloc] init];
    smug.name = @"Smug";
    CollectionItem *i4 = [[CollectionItem alloc] initWithCreature:smug count:0];
    Creature *gumdrop = [[Creature alloc] init];
    gumdrop.name = @"Gumdrop";
    CollectionItem *i5 = [[CollectionItem alloc] initWithCreature:gumdrop count:0];
    Creature *crazedRed = [[Creature alloc] init];
    crazedRed.name = @"CrazedRed";
    CollectionItem *i6 = [[CollectionItem alloc] initWithCreature:crazedRed count:0];
    Creature *worm = [[Creature alloc] init];
    worm.name = @"Worm";
    CollectionItem *i7 = [[CollectionItem alloc] initWithCreature:worm count:0];
    Creature *gumball = [[Creature alloc] init];
    gumball.name = @"Gumball";
    CollectionItem *i8 = [[CollectionItem alloc] initWithCreature:gumball count:0];
    self.collection = [[NSArray alloc] initWithObjects: i1, i2, i3, i4, i5, i6, i7, i8, nil];
    
    NSData *collectionData = [NSKeyedArchiver archivedDataWithRootObject:self.collection];
    NSFileManager *fm = [NSFileManager new];
    NSError *error = nil;
    NSURL *documents = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSURL *collectionFileURL = [documents URLByAppendingPathComponent:@"Collection.dat"];
    NSLog(@"Writing collection to %@", [collectionFileURL absoluteString]);
    NSError *otherError;
    [collectionData writeToURL:collectionFileURL options:0 error:&otherError];

    self.tabBarController.selectedIndex = 0;
}

- (IBAction)noPressed:(id)sender {
    self.tabBarController.selectedIndex = 0;
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