//
//  TripDetails.m
//  Time Traveler
//
//  Created by Sean McDonald on 1/25/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import "TripDetails.h"
#import <Foundation/Foundation.h>


@implementation TripDetails
    
-(void) SetNotifications{
    
    self->notifications = true;
    
}


//Synthesize members of TripDetails class
@synthesize departureMonth = _departureMonth;

@synthesize departureYear = _departureYear;

@synthesize destinationLocation = _destinationLocation;

@synthesize sourceLocation = _sourceLocation;

@synthesize sleepTime = _sleepTime;

@synthesize wakeTime = _wakeTime;

@synthesize departureDay = _departureDay;





@end
