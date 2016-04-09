//
//  Creature.m
//  mapMethod
//
//  Created by Timothy Michael Mathews on 2016-04-01.
//  Copyright © 2016 Tim Mathews. All rights reserved.
//

#import "Creature.h"

@implementation Creature

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name forKey:@"name"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    self.name = [aDecoder decodeObjectForKey:@"name"];
    return self;
}

@end
