//
//  TimeTravelerModel.m
//  TimeTraveler
//
//  Created by Sean P McDonald on 2/21/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import "TimeTravelerModel.h"

@implementation TimeTravelerModel

@synthesize tripSettings;

-(id) init {
    self.tripSettings = [NSUserDefaults standardUserDefaults];
    return self;
}



@end
