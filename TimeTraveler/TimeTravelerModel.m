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


- (NSDate*)adjustSchedule:(NSDate*)normalSchedule daysUntilTrip:(long)deltaD timeZonesCrossed:(long)deltaT shiftAmount:(long)interval {
    
    int flag;
    
    if(deltaT < 0) {
        flag = -1;
    } else {
        flag = 1;
    }
    
    NSDate *adjustedScheduleDate = [NSDate date];
    adjustedScheduleDate = [normalSchedule dateByAddingTimeInterval:flag*interval*60*60];
    return adjustedScheduleDate;
}


- (void)generateSchedule:(long)deltaD timeZonesCrossed:(long)deltaT {
    
    self.wakeScheduleArray = [[NSMutableArray alloc] init];
    self.sleepScheduleArray = [[NSMutableArray alloc] init];
    
    double counter = deltaT;
    double deltaDT = fabsf((double)deltaD / (double)deltaT);
    double interval;
    
    // determine interval
    if (deltaDT >= 1.5) {
        interval = 1.5;
    } else if (deltaDT <= 0.5) {
        interval = 0.5;
    } else {
        interval = 1.0;
    }
   
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    
    //break wake / sleep time in to NSDateComponents
    NSDateComponents *wakeTimeComponent = [gregorian components: (NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit) fromDate:self.selectedWakeTime];
    NSDateComponents *sleepTimeComponent = [gregorian components: (NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit) fromDate:self.selectedSleepTime];
    
    NSDateComponents *tempWake = [gregorian components:NSUIntegerMax fromDate: self.selectedDepartureDate];
    [tempWake setHour: wakeTimeComponent.hour];
    [tempWake setMonth: wakeTimeComponent.minute];
    [tempWake setSecond: wakeTimeComponent.second];
    
    NSDateComponents *tempSleep = [gregorian components:NSUIntegerMax fromDate: self.selectedDepartureDate];
    [tempSleep setHour: sleepTimeComponent.hour];
    [tempSleep setMonth: sleepTimeComponent.minute];
    [tempSleep setSecond: sleepTimeComponent.second];
    
    // Create wake date object
    NSDate *tempWakeDate = [NSDate date];
    tempWakeDate = [gregorian dateFromComponents:tempWake];
    
    // Create sleep Date object
    NSDate *tempSleepDate = [NSDate date];
    tempSleepDate = [gregorian dateFromComponents:tempSleep];
    
    while (counter > 0) {
        
        // Create Sleep Date
        tempWakeDate = [self adjustSchedule:tempWakeDate daysUntilTrip:deltaT timeZonesCrossed:deltaD shiftAmount:interval];
        [self.wakeScheduleArray addObject:tempWakeDate];
        
        // Create Wake Date
        tempSleepDate = [self adjustSchedule:tempSleepDate daysUntilTrip:deltaT timeZonesCrossed:deltaD shiftAmount:interval];
        [self.sleepScheduleArray addObject:tempSleepDate];
        
        [tempWakeDate dateByAddingTimeInterval:-60*60*24];
        [tempSleepDate dateByAddingTimeInterval:-60*60*24];
        
    }
}


@end
