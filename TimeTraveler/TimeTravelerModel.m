//
//  TimeTravelerModel.m
//  TimeTraveler
//
//  Created by Sean P McDonald on 2/21/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import "TimeTravelerModel.h"

@implementation TimeTravelerModel



-(id) init {
    self.tripSettings = [NSUserDefaults standardUserDefaults];
    self.currentTimeZone = [self.tripSettings objectForKey:@"currentTimeZone"];
    self.selectedLocation = [self.tripSettings objectForKey:@"selectedLocation"];
    self.selectedLocationRow = [self.tripSettings objectForKey:@"selectedLocationRow"];
    self.selectedDepartureDate = [self.tripSettings objectForKey:@"selectedDepatureDate"];
    self.selectedSleepTime = [self.tripSettings objectForKey:@"selectedSleepTime"];
    self.selectedWakeTime = [self.tripSettings objectForKey:@"selectedWakeTime"];
    self.selectedNotifications = [self.tripSettings objectForKey:@"selectedNotifications"];
    
    return self;
}

-(long) calculateTimeZoneDifference{
    
    NSTimeZone *selectedTimeZone = [[NSTimeZone alloc] initWithName: self.selectedLocation];
    
    NSLog(@"Offset 1: %ld",(long)[selectedTimeZone secondsFromGMT]);
    NSLog(@"Offset 2: %ld",(long)[self.currentTimeZone secondsFromGMT]);
    
    long currentTimeZoneAdjusted = ((([self.currentTimeZone secondsFromGMT]) / 3600) + 12);
    long destinationTimeZoneAdjusted = ((([selectedTimeZone secondsFromGMT]) / 3600) + 12);
    long deltaTimeZone;
    
    if(destinationTimeZoneAdjusted - currentTimeZoneAdjusted > 12){
        
        deltaTimeZone = (-1)*(24 - (destinationTimeZoneAdjusted - currentTimeZoneAdjusted)); //going west
        
    }
    else if(destinationTimeZoneAdjusted - currentTimeZoneAdjusted < -12){
        
        deltaTimeZone = ((24 - currentTimeZoneAdjusted) + destinationTimeZoneAdjusted); //going east
        
    } else {
        
        deltaTimeZone = destinationTimeZoneAdjusted - currentTimeZoneAdjusted;
        
    }
    
    if(deltaTimeZone == -12)
        deltaTimeZone = (deltaTimeZone * -1);
    
    return deltaTimeZone;
}

-(void) saved {
    
    [NSTimeZone resetSystemTimeZone];
    self.currentTimeZone = [NSTimeZone systemTimeZone];
    NSLog(@"Departure Timezone: %@",[self.currentTimeZone name]);
    
    [self.tripSettings setObject:self.selectedLocation forKey:@"destinationLocation"];
    [self.tripSettings setObject:self.selectedLocationRow forKey:@"destinationLocationRow"];
    [self.tripSettings setObject:self.selectedDepartureDate forKey:@"departureDate"];
    [self.tripSettings setObject:self.selectedSleepTime forKey:@"sleepTime"];
    [self.tripSettings setObject:self.selectedWakeTime forKey:@"wakeTime"];
    [self.tripSettings setObject:self.selectedNotifications forKey:@"notifications"];
    [self.tripSettings synchronize];
    

    
    
    
}



@end
