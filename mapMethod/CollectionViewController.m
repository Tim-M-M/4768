//
//  CollectionViewController.m
//  mapMethod
//
//  Created by Timothy Michael Mathews on 2016-04-09.
//  Copyright © 2016 Tim Mathews. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionItem.h"

@interface CollectionViewController()

@property NSArray<CollectionItem *> *collection;
@property UITableView *tbv;
@end

@implementation CollectionViewController

-(void)viewDidLoad{
    NSLog(@"Did load");
    //[super viewDidLoad];
    [self loadData];
    NSLog(@"Setting title...");
    [self setTitle:@"My Collection"];

}

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
    NSString *str = [NSString stringWithFormat:@"./%@.atlas/frame-1.png",cell.textLabel.text];
    NSLog(str);
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSLog(([fm fileExistsAtPath:str]) ? @"Exists" : @"DNE");
    NSURL *url = [NSURL URLWithString:str];
    NSData *data = [NSData dataWithContentsOfURL:url];
    cell.imageView.image = [UIImage imageWithData:data];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}


-(void)saveData{
    NSLog(@"Saving data...");
    NSData *collectionData = [NSKeyedArchiver archivedDataWithRootObject:self.collection];
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

-(void)loadData{
    NSLog(@"Loading data...");
    NSFileManager *fm = [NSFileManager new];
    NSError *error = nil;
    NSURL *documents = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    
    NSString *collectionFileString = [[documents URLByAppendingPathComponent:@"Collection.dat" ] path];
    if (![fm fileExistsAtPath:collectionFileString]){
        NSLog(@"File not found");
        return;
    }
    NSData *collectionData = [[NSData alloc] initWithContentsOfFile:collectionFileString];
    self.collection = [NSKeyedUnarchiver unarchiveObjectWithData:collectionData];
}


@end
