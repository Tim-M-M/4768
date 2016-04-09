//
//  ViewController.m
//  MapMethod
//
//  Created by Timothy Michael Mathews on 2016-03-28.
//  Copyright © 2016 Tim Mathews. All rights reserved.
//

#import "ViewController.h"
#import "MapAnnotation.h"
#import "CollectionItem.h"
#import "Creature.h"
#import "UIPeerViewController.h"

#define mapRadius = 100;

@interface ViewController ()
@property bool mapSetUp;

//Location
@property (strong, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) CLLocationManager *locMan;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) float secondsLeft;

//User data
@property (strong, nonatomic) NSArray<MapAnnotation *> *areas;
//@property (strong, nonatomic) NSArray<CollectionItem *> *collection;

//Buttons
@property (strong, nonatomic) IBOutlet UIButton *collectionButton;
- (IBAction)collectionButtonPressed:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *gameButton;
- (IBAction)gameButtonPressed:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *tradeButton;
- (IBAction)tradeButtonPressed:(UIButton *)sender;

//Collection
@property (strong, nonatomic) UITableView *tb;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.areas = nil;
    self.mapSetUp = NO;
    self.timer = nil;
    self.secondsLeft = -1;

    
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSURL *documents = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    //NSString *annotationFileString = [[documents URLByAppendingPathComponent:@"Annotations.dat"] path];
    NSString *collectionFileString = [[documents URLByAppendingPathComponent:@"Collection.dat" ] path];
    //NSLog(@"Annotation file at %@ %@", annotationFileString, [fm fileExistsAtPath:annotationFileString] ? @"exists." : @"does not exist.");
    NSLog(@"Collection file at %@ %@", collectionFileString, [fm fileExistsAtPath:collectionFileString] ? @"exists." : @"does not exist.");
    if (/*[fm fileExistsAtPath:annotationFileString] && **/[fm fileExistsAtPath:collectionFileString]){
        NSLog(@"Loading files from viewDidLoad.");
        [self loadData];
        NSLog(@"%lui", (unsigned long)self.areas.count);
    }
    else {
        [self initializeCollectionTo0];
    }
    [self setUpLocMan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initializeCollectionTo0{
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
}

#pragma mark - Initialization functions

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reportScore:)
     name:@"doneAnime"
     object:nil];
    NSLog(@"awakefromnib");
}

-(void)reportScore:(NSNotification *) notification {
    NSDictionary *info = [notification userInfo];
    if ([info objectForKey:@"success"]) {
        NSLog(@"Win");
        NSString *mName = [info objectForKey:@"name"];
        [self incrementCollectionItemWithName:mName positive:YES];
        NSLog(@"%s", [info objectForKey:@"success"] ? "YES" : "NO");
        NSLog(@"%@",self.collection);
    }
    else{
        NSLog(@"Lose");
    }
}


//Sets up the CLLocationManager
- (void) setUpLocMan {
    self.locMan = [[CLLocationManager alloc] init];
    [self.locMan requestAlwaysAuthorization];
    [self.locMan setDelegate:self];
    [self.locMan setDistanceFilter:kCLDistanceFilterNone];
    [self.locMan setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [self.locMan startMonitoringSignificantLocationChanges];
    [self.locMan startUpdatingLocation];
}

//Initializes the map and request authorization for location services.
- (void)generateMap {
    self.map.delegate = self;
    [self.view addSubview:self.map];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted){
        [self.locMan requestAlwaysAuthorization];
    }

    CLLocationCoordinate2D currentLoc = self.locMan.location.coordinate;
    NSLog(@"Current loc: %f, %f", currentLoc.latitude, currentLoc.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLoc, 700, 700);
    [self.map setRegion:region];
    self.map.showsUserLocation = YES;
}
    
#pragma mark - Respond to location updates/CLLocationManager delegate methods

//Respond to change in authorization status by checking for authorization and for if annotations need updating.
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    //NSLog(@"Change in auth status. Location: %f,%f", self.locMan.location.coordinate.latitude, self.locMan.location.coordinate.longitude);
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        if (self.areas == nil) {
            [manager startUpdatingLocation];
            //NSLog(@"Change in auth status. Location: %f,%f", self.locMan.location.coordinate.latitude, self.locMan.location.coordinate.longitude);
        }
    }
}

//On location update check for existence of defined encounter areas
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocationCoordinate2D mostRecentCoord = [locations lastObject].coordinate;
    if (mostRecentCoord.latitude == 0) return;
    //if (self.map == nil) [self generateMap];
    if (!self.mapSetUp) {
        self.mapSetUp = YES;
        [self generateMap];
    }
    if (self.areas == nil) {
        [self.map setBounds:self.view.bounds];
        //NSLog(@"Update: %f,%f", [locations lastObject].coordinate.latitude, [locations lastObject].coordinate.longitude);
        [self.map removeAnnotations:self.map.annotations];
        self.areas = [self generateAnnotations:mostRecentCoord];
        /*
        [self saveData];
        NSFileManager *fm = [[NSFileManager alloc] init];
        NSURL *documents = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
        NSString *annotationFileString = [[documents URLByAppendingPathComponent:@"Annotations.dat"] absoluteString];
        NSString *collectionFileString = [[documents URLByAppendingPathComponent:@"Collection.dat" ] absoluteString];
        NSLog(@"Annotation file at %@ %@", annotationFileString, [fm fileExistsAtPath:annotationFileString] ? @"exists." : @"does not exist. (Post save)");
        NSLog(@"Collection file at %@ %@", collectionFileString, [fm fileExistsAtPath:collectionFileString] ? @"exists." : @"does not exist. (Post save)");
         **/
    }
    if (self.timer == nil) [self setUpTimer];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(nonnull CLRegion *)region {
    if (![region isKindOfClass:[CLCircularRegion class]]) {
        NSLog(@"Region type error");
        return;
    }
    CLCircularRegion *regionCast = (CLCircularRegion *)region;
    MapAnnotation *mapAnn = [self mapAnnotationFromRegion:regionCast];
    if (mapAnn == nil) return;
    mapAnn.isInArea = YES;
    if (self.timer == nil) [self setUpTimer];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(nonnull CLRegion *)region {
    if (![region isKindOfClass:[CLCircularRegion class]]) {
        return;
    }
    CLCircularRegion *regionCast = (CLCircularRegion *)region;
    MapAnnotation *mapAnn = [self mapAnnotationFromRegion:regionCast];
    if (mapAnn == nil) return;
    mapAnn.isInArea = NO;
}

//Generates random encounter locations near the current location provided by self.locMan.
//Is not called until the locationManager updates the location for the first time.
- (NSArray<MapAnnotation *> *)generateAnnotations:(CLLocationCoordinate2D)coord {
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    int annotationNum = 4;
    int minDistance = 200;
    int count = 0;
    for (int i = 0; i < annotationNum; i++) {
        int scope = (i == 0) ? 4 : (i == annotationNum - 1) ? 6 : 5;
        double latOffset = [self makeRandomLatLongDecimalOffset:scope];
        double longOffset = [self makeRandomLatLongDecimalOffset:scope];
        
        latOffset = latOffset + coord.latitude;
        longOffset = longOffset + coord.longitude;
        
        CLLocationCoordinate2D coord;
        coord.latitude = latOffset;
        coord.longitude = longOffset;
        MapAnnotation *pAnn = [[MapAnnotation alloc] initWithLocation:coord rarity:(i == 0)];
        
        bool acceptableDistance = YES;
        for (int i = 0; i < [annotations count]; i++) {
            MKMapPoint this = MKMapPointForCoordinate(coord);
            MKMapPoint that = MKMapPointForCoordinate(((MapAnnotation *)[annotations objectAtIndex:i]).annotation.coordinate);
            CLLocationDistance distanceBetween = MKMetersBetweenMapPoints(this, that);
            //  NSLog(@"Distance: %f", distanceBetween);
            if (distanceBetween < minDistance) {
                //       NSLog(@"Unacceptable");
                acceptableDistance = NO;
            }
        }
        
        count++;
        if (acceptableDistance) {
            pAnn.annotation.coordinate = coord;
            pAnn.annotation.title = [NSString stringWithFormat:@"Title %d", i];
            pAnn.annotation.subtitle = @"Subtitle";
            pAnn.close = i != 1;
            
            MKCircle *regionCircle = [MKCircle circleWithCenterCoordinate:coord radius:150];
            regionCircle.title = [NSString stringWithFormat:@"Region %d", i];
            
            [self.map addOverlay:regionCircle];
            [self.map addAnnotation:pAnn.annotation];
            [annotations addObject:pAnn];
            [self.locMan startMonitoringForRegion:pAnn.region];
        }
        else {
            i = (count >= 150) ? annotationNum : i - 1;
            NSLog(@"Else condition");
        }
    }
    //[self addRegionsToMap:self.areas];
    NSArray<MapAnnotation *> *temp = [[NSArray alloc] initWithArray:annotations];
    return temp;
}

#pragma mark - Map delegate methods

//Color in region around circle
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        renderer.fillColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3];
        return renderer;
    }
    return nil;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MapAnnotation class]]) {
        MapAnnotation *mapAnn = (MapAnnotation *) annotation;
        MKAnnotationView *annView = [self.map dequeueReusableAnnotationViewWithIdentifier:@"MapAnnotation"];
        if (annView == nil){
            annView = [mapAnn annView];
        }
        else {
            annView.annotation = annotation;
        }
        return annView;
    }
    return nil;
}

#pragma mark - Timer methods

-(void)setUpTimer{
    //self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timerTarget) userInfo:nil repeats:YES];
    //self.secondsLeft = 10 * ((arc4random() % 4) + 2);
   //NSLog(@"Timer started for %f seconds", self.secondsLeft);
}

-(void)timerTarget{
    bool secondsDecrement = NO;
    for (int i = 0; i < [self.areas count]; i++) {
        if ([[self.areas objectAtIndex:i].region containsCoordinate:[self.locMan location].coordinate]) secondsDecrement = YES;
    }
    if (secondsDecrement) {
    self.secondsLeft -= 10;
        if (self.secondsLeft == 0) {
            //[self triggerEncounter];
            NSLog(@"Encounter!");
            [self.timer invalidate];
        }
    }
}

#pragma mark - Handle buttons

-(IBAction)collectionButtonPressed:(UIButton *)sender {
    if (self.tb == nil) self.tb = [[UITableView alloc] init];
    [self.tb reloadData];
    [self.tb setDelegate:self];
    [self.tb setDataSource:self];
    [self.tb setRowHeight:100];
    [self.tb setEditing:NO];
    
    UITableViewController *tvc = [[UITableViewController alloc] init];
    [tvc setTitle:@"My Collection"];
    [tvc setTableView:self.tb];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:tvc];
    nc.modalPresentationStyle = UIModalPresentationPopover;
    nc.popoverPresentationController.sourceView = sender;
    [self presentViewController:nc animated:YES completion:nil];
}



- (IBAction)gameButtonPressed:(UIButton *)sender {
    //[self.map removeOverlays:self.map.overlays];
    //[self viewDidLoad];
    [self saveData];
}

- (IBAction)tradeButtonPressed:(UIButton *)sender {
    NSLog(@"Trade button pressed");
    [self saveData];
    [self performSegueWithIdentifier:@"trade_segue" sender:self];
    
}

#pragma mark - UITableViewDataSourceDelegate functions

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.collection count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Identifier"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    cell.textLabel.text = [self.collection objectAtIndex:indexPath.row].creature.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [self.collection objectAtIndex:indexPath.row].count];
    return cell;
}

#pragma mark - Utility functions

//Creates random numbers with small absolute values for randomized latitude/longitude offsets
-(double)makeRandomLatLongDecimalOffset:(int)scope{
    double returnVal = 0;
    for (int i = -1; i >= -scope; i--) {
        returnVal += ((arc4random() % 10) * pow(10, (i + (2 + (1 - scope)))));
    }
    if ((arc4random() %2) == 0) returnVal = -returnVal;
    return returnVal;
}

//Return the MapAnnotation in self.areas with the input region
-(MapAnnotation *)mapAnnotationFromRegion:(CLCircularRegion *)region {
    MapAnnotation *mapAnn = nil;
    for (int i = 0; i < [self.areas count]; i++){
        if ([((MapAnnotation *)[self.areas objectAtIndex:i]).region isEqual:region]) {
            mapAnn = ((MapAnnotation *)[self.areas objectAtIndex:i]);
            return mapAnn;
        }
    }
    return mapAnn;
}

-(void)incrementCollectionItemWithName:(NSString *)mName positive:(BOOL)inc{
    int deltaCount = inc ? 1 : -1;
    for (CollectionItem *collItem in self.collection) {
        if ([mName isEqualToString:collItem.creature.name]) {
            collItem.count = collItem.count + deltaCount;
            [self saveData];
            return;
        }
    }
}

/*
-(void)addRegionsToMap:(NSArray <MapAnnotation *> *) annotations{
    NSLog(@"Addregionscalled, length: %lu", (unsigned long)[annotations count]);
    for (int i = 0; i < [annotations count]; i++) {
        MKCircle *regionCircle = [MKCircle circleWithCenterCoordinate:[annotations objectAtIndex:i].annotation.coordinate radius:150];
        NSLog(@"%f,%f", regionCircle.coordinate.latitude, regionCircle.coordinate.longitude);
        regionCircle.title = [NSString stringWithFormat:@"Region %d", i + 1];
        [self.map addOverlay:regionCircle];
        NSLog(@"Region added");
    }
    self.map.centerCoordinate = CLLocationCoordinate2DMake(0, 0);
    [self.map setNeedsDisplay];
    
}
 **/


#pragma mark - Persistence

-(void)saveData{
    NSLog(@"Saving data...");
    NSData *areaData = [NSKeyedArchiver archivedDataWithRootObject:self.areas];
    NSData *collectionData = [NSKeyedArchiver archivedDataWithRootObject:self.collection];
    NSFileManager *fm = [NSFileManager new];
    NSError *error = nil;
    NSURL *documents = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSURL *annotationFileURL = [documents URLByAppendingPathComponent:@"Annotations.dat"];
    NSURL *collectionFileURL = [documents URLByAppendingPathComponent:@"Collection.dat"];
    NSLog(@"Writing annotations to %@", [annotationFileURL absoluteString]);
    if ([areaData writeToURL:annotationFileURL atomically:YES]) NSLog(@"Writing of areas successful");
    NSLog(@"Writing collection to %@", [collectionFileURL absoluteString]);
    NSError *otherError;
    [collectionData writeToURL:collectionFileURL options:0 error:&otherError];
    if (otherError) {
        NSLog(@"Error: %@", [otherError localizedDescription]);
    }
    else {
        NSLog(@"No error");
    }
    return;
}

-(void)loadData{
    NSLog(@"Loading data...");
    NSFileManager *fm = [NSFileManager new];
    NSError *error = nil;
    NSURL *documents = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    
    //NSString *annotationFileString = [[documents URLByAppendingPathComponent:@"Annotations.dat"] path];
    NSString *collectionFileString = [[documents URLByAppendingPathComponent:@"Collection.dat" ] path];
    if (/*![fm fileExistsAtPath:annotationFileString] ||**/ ![fm fileExistsAtPath:collectionFileString]){
        NSLog(@"File not found");
        return;
    }
    /*
    NSData *areasData = [[NSData alloc] initWithContentsOfFile:annotationFileString];
    
    NSLog(@"About to assign areas");
    NSArray<MapAnnotation *> *areasTemp = [NSKeyedUnarchiver unarchiveObjectWithData:areasData];
    NSLog(@"Areas assigned");
    if ([areasTemp count] == 0){
        NSLog(@"0 Length array problem");
        return;
    }
    else{
        NSLog(@"Length: %lu", (unsigned long)areasTemp.count);
    }
    for (MapAnnotation *mapAnn in areasTemp) {
        NSLog(@"Annotation location: %f, %f", mapAnn.annotation.coordinate.latitude, mapAnn.annotation.coordinate.longitude);
    }
    self.areas = areasTemp;
    **/
    NSData *collectionData = [[NSData alloc] initWithContentsOfFile:collectionFileString];
    self.collection = [NSKeyedUnarchiver unarchiveObjectWithData:collectionData];
    NSLog(@"Collections set with length %lu", self.collection.count);
    if (self.collection.count == 0) [self initializeCollectionTo0];
    /*
    [self.map removeOverlays:self.map.overlays];
    for (int i = 0; i < self.areas.count; i++) {
        MapAnnotation *mapAnn = [self.areas objectAtIndex:i];
        [self.map addAnnotation:mapAnn.annotation];
        MKCircle *regionCircle = [MKCircle circleWithCenterCoordinate:mapAnn.annotation.coordinate radius:150];
        regionCircle.title = [NSString stringWithFormat:@"Region %d", i];
        [self.map addAnnotation:[self.areas objectAtIndex:i].annotation];
        [self.locMan startMonitoringForRegion:mapAnn.region];
    }
    **/
}


@end
