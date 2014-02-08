//
//  TripDetails.h
//  Time Traveler
//
//  Created by Sean McDonald on 1/25/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 *Class TripDetails
 *[Description] Class used in "model" implementation, contains 
 *info on user schedule
 *[preconditions] none
 *[input] dateTime, location
 *[output] none
 *
 */


@interface TripDetails : NSObject{
    
    
    NSInteger departureDay;
    NSInteger departureMonth;
    NSInteger departureYear;
    NSInteger sourceLocation;
    NSInteger destinationLocation;
    Boolean notifications;
    NSInteger wakeTime;
    NSInteger sleepTime;
    
}

-(void) SetNotifications;

//creation of location and dateTime properties

@property NSInteger departureDay;

@property NSInteger departureMonth;

@property NSInteger departureYear;

@property NSInteger sourceLocation;

@property NSInteger destinationLocation;

@property NSInteger wakeTime;

@property NSInteger sleepTime;


@end
