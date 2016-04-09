//
//  CollectionItem.m
//  mapMethod
//
//  Created by Timothy Michael Mathews on 2016-04-01.
//  Copyright © 2016 Tim Mathews. All rights reserved.
//

#import "CollectionItem.h"

@implementation CollectionItem

-(id)initWithCreature:(Creature *)creature count:(int)count{
    self = [super init];
    self.creature = creature;
    self.count = count;
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.creature forKey:@"creature"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.count] forKey:@"count"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    self.creature = [aDecoder decodeObjectForKey:@"creature"];
    self.count = [[aDecoder decodeObjectForKey:@"count"] intValue];
    return self;
}

@end
