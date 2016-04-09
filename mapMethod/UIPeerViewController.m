//
//  UIPeerViewController.m
//  mapMethod
//
//  Created by Timothy Michael Mathews on 2016-04-03.
//  Copyright © 2016 Tim Mathews. All rights reserved.
//

#import "UIPeerViewController.h"
#import "ViewController.h"//;

@interface UIPeerViewController ()

@property (strong, nonatomic) NSArray<CollectionItem *> *ourCollection;
@property (strong, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) IBOutlet UIButton *connectButton;
- (IBAction)connectButtonPressed:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *offerButton;
- (IBAction)offerButtonPressed:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *myCollectionLabel;
/*
@property (strong, nonatomic) IBOutlet UIPickerView *myPicker;
@property (strong, nonatomic) IBOutlet UIPickerView *theirPicker;
**/
@property (strong, nonatomic) IBOutlet NSArray<NSString *> *theirCollection;

@property (strong, nonatomic) IBOutlet UITableView *ourTable;
@property (strong, nonatomic) IBOutlet UITableView *theirTable;


@property (strong, nonatomic) UIAlertController *alert;



//Multipeer
@property (strong, nonatomic) MCPeerID *peerID;
@property (strong, nonatomic) MCAdvertiserAssistant *assistant;
@property (strong, nonatomic) MCBrowserViewController *browser;
@property (strong, nonatomic) MCSession *session;

@end

@implementation UIPeerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    // Do any additional setup after loading the view.
    self.ourTable.delegate = self;
    self.ourTable.dataSource =self;
    self.theirTable.delegate = self;
    self.theirTable.dataSource = self;
    [self setConnected:NO];
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSURL *documents = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSString *collectionFileString = [[documents URLByAppendingPathComponent:@"Collection.dat" ] path];
    NSLog(@"Collection file at %@ %@", collectionFileString, [fm fileExistsAtPath:collectionFileString] ? @"exists." : @"does not exist.");
    if (/*[fm fileExistsAtPath:annotationFileString] && **/[fm fileExistsAtPath:collectionFileString]){
        NSLog(@"Loading files from viewDidLoad.");
        [self loadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setConnected:(BOOL)connectedNow{
    dispatch_async(dispatch_get_main_queue(), ^{
      //  self.ourTable.hidden = !connectedNow;
      //  self.ourTable.hidden = !connectedNow;
        //self.myCollectionLabel.hidden = !connectedNow;
        self.offerButton.enabled = connectedNow;
        [self.view setNeedsDisplay];
    });
}


#pragma mark - Navigation

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Preparing...");
    self.vc = (ViewController *)sender;
    NSLog(@"%@", self.ourCollection);
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
**/


-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];    
}

#pragma mark - MCSessionDelegate methods

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSLog(@"Received Data");
    NSString *str = [[NSString alloc] initWithData:data encoding: NSASCIIStringEncoding];
    NSLog(str);
    NSArray *arr = [str componentsSeparatedByString:@","];
    if([[arr objectAtIndex:0] isEqualToString:@"trade"]){
        // data sent as @"trade,Yourname,Myname"
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Trade Request"
                                                                           message:[NSString stringWithFormat:@"%@ wishes to trade %@ for %@", peerID.displayName,[arr objectAtIndex:1],[arr objectAtIndex:2]]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self incrementCollectionItemWithName:[arr objectAtIndex:1] positive:YES];
                [self incrementCollectionItemWithName:[arr objectAtIndex:2] positive:NO];
                //Accepted,whatYouGained,whatYouLost
                [self.session sendData:[[NSString stringWithFormat:@"Accepted,%@,%@", [arr objectAtIndex:2], [arr objectAtIndex:1]] dataUsingEncoding:NSASCIIStringEncoding] toPeers:session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
                UIAlertController *alertAccepted = [UIAlertController alertControllerWithTitle:@"Trade Completed"
                                                                                       message:@"Returning to map..."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                self.alert = alertAccepted;
                [self presentViewController:alertAccepted animated:YES completion:nil];
                [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(executePostTradeSegue) userInfo:nil repeats:NO];
            }];
            
            UIAlertAction *rejectAction = [UIAlertAction actionWithTitle:@"Reject" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self.session sendData:[@"Rejected" dataUsingEncoding:NSASCIIStringEncoding] toPeers:session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
                if (self.alert != nil){
                    [self.alert dismissViewControllerAnimated:YES completion:nil];
                }
            }];
            
            [alert addAction:acceptAction];
            [alert addAction:rejectAction];
            [self presentViewController:alert animated:YES completion:nil];

        });
    } else if([[arr objectAtIndex:0] isEqualToString:@"load"]){
        dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *theirs = [[NSMutableArray alloc] init];
        //load,names
        for (int i = 1; i < arr.count; i++) {
            [theirs addObject:[arr objectAtIndex:i]];
        }
        self.theirCollection = [NSArray arrayWithArray:theirs];
        [self.theirTable reloadData];
        });
    }
    else if([[arr objectAtIndex:0] isEqualToString:@"Accepted"]){
        dispatch_async(dispatch_get_main_queue(), ^{
        [self incrementCollectionItemWithName:[arr objectAtIndex:1] positive:YES];
        [self incrementCollectionItemWithName:[arr objectAtIndex:2] positive:NO];
        if (self.alert != nil){
            [self.alert dismissViewControllerAnimated:YES completion:nil];
        }
        [self.ourTable reloadData];
        [self.theirTable reloadData];
            
        [self setConnected:NO];
        [self.session disconnect];
        [self saveData];
        UIAlertController *alertAccepted = [UIAlertController alertControllerWithTitle:@"Trade Completed"
                                                                        message:@"Returning to map..."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        self.alert = alertAccepted;
        [self presentViewController:alertAccepted animated:YES completion:nil];
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(executePostTradeSegue) userInfo:nil repeats:NO];
        });
    }
    else if([[arr objectAtIndex:0] isEqualToString:@"Rejected"]){
        NSLog(@"Rejected !!!!!!\n\n\n\n\n\n\n\n\n\n");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.alert != nil){
                [self.alert dismissViewControllerAnimated:YES completion:nil];
            }
            UIAlertController* alertRejected = [UIAlertController alertControllerWithTitle:@"Request Denied"
                                                                        message:@"Your offer was rejected."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
            self.alert = alertRejected;
            [self presentViewController:alertRejected animated:YES completion:nil];
            [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(removeRejectionAlert) userInfo:nil repeats:NO];
            [self setConnected:NO];
            [self.session disconnect];
            [self viewDidLoad];
        });
    }
}

-(void)removeRejectionAlert{
    [self.alert dismissViewControllerAnimated:YES completion:nil];
    self.alert = nil;
}

-(void)incrementCollectionItemWithName:(NSString *)mName positive:(BOOL)inc{
    int deltaCount = inc ? 1 : -1;
    for (CollectionItem *collItem in self.ourCollection) {
        if ([mName isEqualToString:collItem.creature.name]) {
            collItem.count = collItem.count + deltaCount;
            [self saveData];
            return;
        }
    }
}


-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    if (state == MCSessionStateConnected) {
        NSLog(@"State connected");
        [self setConnected:YES];
        [self.ourTable reloadData];
        [self.theirTable reloadData];
        NSString *stringToSend = @"load";
        for (CollectionItem *collItem in self.ourCollection) {
            if (collItem.count > 0) stringToSend = [NSString stringWithFormat:@"%@,%@", stringToSend, collItem.creature.name];
        }
        NSError *error;
        NSArray *peers = self.session.connectedPeers;
        NSLog(@"%@", peers);
        NSLog(@"%lu", (unsigned long)session.connectedPeers.count);
        BOOL a = [self.session sendData:[stringToSend dataUsingEncoding:NSASCIIStringEncoding] toPeers:peers  withMode:MCSessionSendDataReliable error:&error];
        if (a){
            NSLog(@"OK");
        }
        else {
            NSLog(@"Not OK");
        }
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        else {
            NSLog(@"No error");
        }
    }   
    else {
        [self setConnected:NO];
    }
}

- (IBAction)connectButtonPressed:(UIButton *)sender {
    self.peerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    NSLog(@"%@", self.peerID.displayName);
    self.session = [[MCSession alloc] initWithPeer:self.peerID];
    self.session.delegate = self;
    self.assistant = [[MCAdvertiserAssistant alloc] initWithServiceType:@"Trading" discoveryInfo:nil session:self.session];
    [self.assistant start];
    self.browser = [[MCBrowserViewController alloc] initWithServiceType:@"Trading" session:self.session];
    self.browser.delegate = self;
    [self presentViewController:self.browser animated:YES completion:nil];
}
- (IBAction)offerButtonPressed:(UIButton *)sender {
    NSString *myItem = [self.ourCollection objectAtIndex:[self.ourTable indexPathForSelectedRow].row].creature.name;
    NSString *theirItem = [self.theirCollection objectAtIndex:[self.theirTable indexPathForSelectedRow].row];
    NSArray *peerId = _session.connectedPeers;
    //send offer @"trade,Yourname,myname"
    [self.session sendData:[[NSString stringWithFormat:@"trade,%@,%@",myItem,theirItem] dataUsingEncoding:NSASCIIStringEncoding]toPeers:peerId withMode:MCSessionSendDataReliable error:nil];
    self.alert = [UIAlertController alertControllerWithTitle:@"Waiting on other player..." message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:self.alert animated:YES completion:nil];
}

#pragma mark - UIPickerViewDelegate methods

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSLog(@"pickerview titleforrow called");
    if (pickerView.tag == 1000) {
        NSMutableArray<CollectionItem *> *myItems = [[NSMutableArray alloc] init];
        for (CollectionItem *collItem in self.ourCollection) {
            if (collItem.count > 0) [myItems addObject:collItem];
        }
        return [NSString stringWithFormat:@"%@: %d", [myItems objectAtIndex:row].creature.name, [myItems objectAtIndex:row].count];
        
    }
    else if (pickerView.tag == 1001) {
        return [self.theirCollection objectAtIndex:row];
    }
    else {
        return @"ERROR";
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    return;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
    
}

-(NSInteger)pickerView:(UIPickerView *)picker numberOfRowsInComponent:(NSInteger)component{
    if (picker.tag == 1000) {
        NSMutableArray *mutArr;
        for (CollectionItem *collItem in _ourCollection) {
            if (collItem.count > 0){
                [mutArr addObject:collItem];
            }
        }
        return mutArr.count;
    }
    else if (picker.tag == 1001) {
        NSMutableArray *mutArr;
        for (CollectionItem *collItem in self.theirCollection) {
            if (collItem.count > 0){
                [mutArr addObject:collItem];
            }
        }
        return mutArr.count;
    }
    else return  100;
}

-(void)loadData{
    NSLog(@"Loading data...");
    NSFileManager *fm = [NSFileManager new];
    NSError *error = nil;
    NSURL *documents = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    
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
    
    self.ourCollection = [NSKeyedUnarchiver unarchiveObjectWithData:collectionData];
    if (self.ourCollection.count == 0) NSLog(@"ERROR :(");
}

-(void)saveData{
    NSLog(@"Saving data...");
    NSData *collectionData = [NSKeyedArchiver archivedDataWithRootObject:self.ourCollection];
    NSFileManager *fm = [NSFileManager new];
    NSError *error = nil;
    NSURL *documents = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSURL *collectionFileURL = [documents URLByAppendingPathComponent:@"Collection.dat"];
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

-(void)executePostTradeSegue{
    [self performSegueWithIdentifier:@"goBack" sender:nil];
}

#pragma mark - UITableViewDelegate methods




#pragma mark - UITableViewDataSourceDelegate methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Identifier"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.textLabel.text = (tableView.tag == 1000) ? [self.ourCollection objectAtIndex:indexPath.row].creature.name: [self.theirCollection objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = (tableView.tag == 1000) ? [NSString stringWithFormat:@"%d", [self.ourCollection objectAtIndex:indexPath.row].count] : @"";
    });
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 1000) {
        return self.ourCollection.count;
    }
    else if (tableView.tag == 1001){
        if (self.theirCollection) return self.theirCollection.count;
        return 8;
    }
    NSLog(@"ERROR: TableView #Rows/Section");
    return 8;
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self saveData];
}

@end
