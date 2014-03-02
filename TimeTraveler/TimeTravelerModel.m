//
//  TimeTravelerModel.m
//  TimeTraveler
//
//  Created by Sean P McDonald on 2/21/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import "TimeTravelerModel.h"

@implementation TimeTravelerModel


- (id)init {

    [self update];
    return self;
    
}


- (void)update {
    
    self.currentTimeZone = [NSTimeZone systemTimeZone];
    
    NSUserDefaults *tripSettings = [NSUserDefaults standardUserDefaults];
    
    self.selectedLocation = [tripSettings objectForKey:@"destinationLocation"];
    self.selectedLocationRow = [tripSettings objectForKey:@"destinationLocationRow"];
    self.selectedDepartureDate = [tripSettings objectForKey:@"departureDate"];
    self.selectedSleepTime = [tripSettings objectForKey:@"sleepTime"];
    self.selectedWakeTime = [tripSettings objectForKey:@"wakeTime"];
    self.selectedNotifications = [tripSettings objectForKey:@"notifications"];
    
}


- (void)save {
    
    [NSTimeZone resetSystemTimeZone];
    self.currentTimeZone = [NSTimeZone systemTimeZone];
    NSLog(@"Departure Timezone: %@",[self.currentTimeZone name]);
    
    NSUserDefaults *tripSettings = [NSUserDefaults standardUserDefaults];
    
    [tripSettings setObject:self.selectedLocation forKey:@"destinationLocation"];
    [tripSettings setObject:self.selectedLocationRow forKey:@"destinationLocationRow"];
    [tripSettings setObject:self.selectedDepartureDate forKey:@"departureDate"];
    [tripSettings setObject:self.selectedSleepTime forKey:@"sleepTime"];
    [tripSettings setObject:self.selectedWakeTime forKey:@"wakeTime"];
    [tripSettings setObject:self.selectedNotifications forKey:@"notifications"];
    [tripSettings synchronize];
    
}


- (NSDate*)adjustSchedule:(NSDate*)normalSchedule daysUntilTrip:(int)deltaD timeZonesCrossed:(int)deltaT shiftAmount:(int)deltaDT {
    
    int flag;
    
    if(deltaT < 0) {
        
        flag = -1;
        
    } else {
        
        flag = 1;
    
    }
    
    NSDate *adjustedScheduleDate = [NSDate date];
    
    if (deltaDT >= 1.5) {
        
    
        adjustedScheduleDate = [normalSchedule dateByAddingTimeInterval:flag*60*90];
        
        
    } else if (deltaDT <= 0.5) {
        
        
        adjustedScheduleDate = [normalSchedule dateByAddingTimeInterval:flag*60*30];
        
        
    } else {
        if (deltaDT <= 1) {
        
            adjustedScheduleDate = [normalSchedule dateByAddingTimeInterval:flag*60*60];
            
            
        } else {
            
            adjustedScheduleDate = [normalSchedule dateByAddingTimeInterval:flag*60*90];
            
        }
    }
    
    return adjustedScheduleDate;
}


- (NSMutableArray *) generateSchedule :(int)deltaD timeZonesCrossed:(int)deltaT {
    NSMutableArray* schedule = [[NSMutableArray alloc] init];
    
    float counter = deltaT;
    float deltaDT = fabsf((float)deltaD / (float)deltaT);
    
    while (counter) {
        if (deltaDT >= 1.5) {
            
            
        } else if (deltaDT <= 0.5) {
            
        } else { // 1
            
        }
        
    }

    return schedule;
}


@end
