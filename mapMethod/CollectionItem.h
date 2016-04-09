//
//  CollectionItem.h
//  mapMethod
//
//  Created by Timothy Michael Mathews on 2016-04-01.
//  Copyright © 2016 Tim Mathews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Creature.h"

@interface CollectionItem : NSObject <NSCoding>
@property (nonatomic, strong) Creature *creature;
@property (nonatomic) int count;
-(id)initWithCreature:(Creature *)creature count:(int)count;
@end
