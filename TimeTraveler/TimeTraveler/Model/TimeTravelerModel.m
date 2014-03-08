//
//  TimeTravelerModel.m
//  TimeTraveler
//
//  Created by Sean P McDonald on 2/21/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import "TimeTravelerModel.h"

@implementation TimeTravelerModel


+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}


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


- (long)calculateTimeZoneDifference{
    
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


- (void)generateSchedule
{
    
    long deltaD = (long)[TimeTravelerModel daysBetweenDate:[NSDate date] andDate:self.selectedDepartureDate];
    long deltaT = [self calculateTimeZoneDifference];
    
    self.wakeScheduleArray = [[NSMutableArray alloc] init];
    self.sleepScheduleArray = [[NSMutableArray alloc] init];
    
    double deltaDT = fabsf((double)deltaD / (double)deltaT);
    double interval;
    
    int flag;
    
    if(deltaT < 0) {
        flag = -1;
    } else {
        flag = 1;
    }
    
    // determine interval
    if (deltaDT >= 1.5) {
        interval = 1.5;
    } else if (deltaDT <= 0.5) {
        interval = 0.5;
    } else {
        interval = 1.0;
    }
    
    //break wake / sleep time in to NSDateComponents
    NSDateComponents *wakeTimeComponent = [[NSCalendar currentCalendar] components: (NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond) fromDate:self.selectedWakeTime];

    NSDateComponents *sleepTimeComponent = [[NSCalendar currentCalendar] components: (NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond) fromDate:self.selectedSleepTime];
    
    NSDateComponents *dayComponent = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:self.selectedDepartureDate];
    
    // Create wake date object
    NSDateComponents *tempWake = [[NSDateComponents alloc] init];
    [tempWake setYear: [dayComponent year]];
    [tempWake setMonth:[dayComponent month]];
    [tempWake setDay:[dayComponent day]];
    [tempWake setHour: [wakeTimeComponent hour]];
    [tempWake setMinute: [wakeTimeComponent minute]];
    [tempWake setSecond: [wakeTimeComponent second]];
    NSDate *tempWakeDate = [[NSCalendar currentCalendar] dateFromComponents:tempWake];
    
    // Create sleep Date object
    NSDateComponents *tempSleep = [[NSDateComponents alloc] init];
    [tempSleep setYear: [dayComponent year]];
    [tempSleep setMonth:[dayComponent month]];
    [tempSleep setDay:[dayComponent day]];
    [tempSleep setHour: [sleepTimeComponent hour]];
    [tempSleep setMinute: [sleepTimeComponent minute]];
    [tempSleep setSecond: [sleepTimeComponent second]];
    NSDate *tempSleepDate = [[NSCalendar currentCalendar] dateFromComponents:tempSleep];
    
    for (double counter = deltaT; counter > 0; counter--) {

        // Create Sleep Date
        tempWakeDate = [tempWakeDate dateByAddingTimeInterval:flag*interval*60*60];
        [self.wakeScheduleArray addObject:tempWakeDate];
        
        // Create Wake Date
        tempSleepDate = [tempSleepDate dateByAddingTimeInterval:flag*interval*60*60];
        [self.sleepScheduleArray addObject:tempSleepDate];
        
        // Decrement Day
        tempWakeDate = [tempWakeDate dateByAddingTimeInterval:-60*60*24];
        tempSleepDate = [tempSleepDate dateByAddingTimeInterval:-60*60*24];
        
    }
    
    // Reverse array
    self.wakeScheduleArray = [[[self.wakeScheduleArray reverseObjectEnumerator] allObjects] mutableCopy];
    self.sleepScheduleArray = [[[self.sleepScheduleArray reverseObjectEnumerator] allObjects] mutableCopy];
}


@end
