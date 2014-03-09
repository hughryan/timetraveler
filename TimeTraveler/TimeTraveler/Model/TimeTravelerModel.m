//
//  TimeTravelerModel.m
//  TimeTraveler
//
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
    
    [self determineTimeTillDeparture];
    
}


- (void)save {
    
    [NSTimeZone resetSystemTimeZone];
    self.currentTimeZone = [NSTimeZone localTimeZone];
    NSLog(@"Departure Timezone: %@",[self.currentTimeZone name]);
    
    NSUserDefaults *tripSettings = [NSUserDefaults standardUserDefaults];
    
    [tripSettings setObject:self.selectedLocation forKey:@"destinationLocation"];
    [tripSettings setObject:self.selectedLocationRow forKey:@"destinationLocationRow"];
    [tripSettings setObject:self.selectedDepartureDate forKey:@"departureDate"];
    [tripSettings setObject:self.selectedSleepTime forKey:@"sleepTime"];
    [tripSettings setObject:self.selectedWakeTime forKey:@"wakeTime"];
    [tripSettings setObject:self.selectedNotifications forKey:@"notifications"];
    [tripSettings synchronize];
    
    [self determineTimeTillDeparture];
    
}


- (void)determineTimeTillDeparture {
    
    NSDate *today = [NSDate date];
    
    NSDate *zeroHour = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: zeroHour];
    [components setHour: 00];
    [components setMinute: 00];
    [components setSecond: 00];
    zeroHour = [gregorian dateFromComponents: components];
    
    self.secInDay = 86400;
    self.timeTillDeparture = [self.selectedDepartureDate timeIntervalSinceNow];
    self.secondsPassedToday = [today timeIntervalSinceDate:zeroHour];
    
}


- (long)calculateTimeZoneDifference{
    
    NSTimeZone *selectedTimeZone = [[NSTimeZone alloc] initWithName: self.selectedLocation];
    
    //NSLog(@"Destination TimeZone Offset: %ld",(long)[selectedTimeZone secondsFromGMT]);
    //NSLog(@"Current TimeZone Offset: %ld",(long)[self.currentTimeZone secondsFromGMT]);
    
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
    
    self.wakeScheduleArray = [[NSMutableArray alloc] init];
    self.sleepScheduleArray = [[NSMutableArray alloc] init];
    
    long daysBeforeDeparture = (long)[TimeTravelerModel daysBetweenDate:[NSDate date] andDate:self.selectedDepartureDate] + 1;
    NSLog(@"Days Before Departure: %ld", daysBeforeDeparture);
    
    long timeZoneChange = [self calculateTimeZoneDifference];
    NSLog(@"Timezone Change Undergone: %ld", timeZoneChange);

    double estimatedScheduleAdjustmentInterval = fabs((double)timeZoneChange / (double)daysBeforeDeparture);
    NSLog(@"Estimated Schedule Adjustment Interval: %lf", estimatedScheduleAdjustmentInterval);
    
    // determine direction
    int flag;
    if(timeZoneChange <= 0) flag = 1; else flag = -1;
    
    // determine interval
    double interval;
    if (estimatedScheduleAdjustmentInterval >= 1.5) {
        interval = 1.5;
    } else if (estimatedScheduleAdjustmentInterval <= 0.5) {
        interval = 0.5;
    } else {
        interval = 1.0;
    }
    NSLog(@"Adjusted Interval: %lf", interval);
    
    //break wake/sleep time in to NSDateComponents
    NSDateComponents *wakeTimeComponent = [[NSCalendar currentCalendar] components: (NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond) fromDate:self.selectedWakeTime];
    NSDateComponents *sleepTimeComponent = [[NSCalendar currentCalendar] components: (NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond) fromDate:self.selectedSleepTime];
    NSDateComponents *dayComponent = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:self.selectedDepartureDate];
    
    // Create wake date object
    NSDateComponents *tempWake = [[NSDateComponents alloc] init];
    [tempWake setYear: [dayComponent year]];
    [tempWake setMonth:[dayComponent month]];
    [tempWake setDay: [dayComponent day]];
    [tempWake setHour: [wakeTimeComponent hour]];
    [tempWake setMinute: [wakeTimeComponent minute]];
    [tempWake setSecond: [wakeTimeComponent second]];
    NSDate *tempWakeDate = [[NSCalendar currentCalendar] dateFromComponents:tempWake];
    
    // Create sleep Date object
    NSDateComponents *tempSleep = [[NSDateComponents alloc] init];
    [tempSleep setYear: [dayComponent year]];
    [tempSleep setMonth:[dayComponent month]];
    [tempSleep setDay: [dayComponent day]];
    [tempSleep setHour: [sleepTimeComponent hour]];
    [tempSleep setMinute: [sleepTimeComponent minute]];
    [tempSleep setSecond: [sleepTimeComponent second]];
    NSDate *tempSleepDate = [[NSCalendar currentCalendar] dateFromComponents:tempSleep];

    // determine how many days will be adjusted
    long daysToBeAdjusted = 0;
    for (double temp = fabs(timeZoneChange); temp > 0; temp -= interval) daysToBeAdjusted++;
    if (daysToBeAdjusted > daysBeforeDeparture) daysToBeAdjusted = daysBeforeDeparture;
    NSLog(@"Days to be adjusted: %ld", daysToBeAdjusted);
    
    // set dates to first day of adjustments
    tempWakeDate = [tempWakeDate dateByAddingTimeInterval:(-(daysToBeAdjusted - 1)*60*60*24)];
    tempSleepDate = [tempSleepDate dateByAddingTimeInterval:(-(daysToBeAdjusted - 1)*60*60*24)];
    
    //NSLog(@"wake origin: %@", tempWakeDate);
    //NSLog(@"sleep origin: %@", tempSleepDate);
   
    //NSLog(@"true wake origin: %@", self.selectedWakeTime);
    //NSLog(@"true sleep origin: %@", self.selectedSleepTime);

    while (daysToBeAdjusted > 0) {
        
        // Create Sleep Date
        tempWakeDate = [tempWakeDate dateByAddingTimeInterval:flag*interval*60*60];
        [self.wakeScheduleArray addObject:tempWakeDate];

        // Create Wake Date
        tempSleepDate = [tempSleepDate dateByAddingTimeInterval:flag*interval*60*60];
        [self.sleepScheduleArray addObject:tempSleepDate];
        
        // Increment Day
        tempWakeDate = [tempWakeDate dateByAddingTimeInterval:60*60*24];
        tempSleepDate = [tempSleepDate dateByAddingTimeInterval:60*60*24];
        
        --daysToBeAdjusted;
        
    }
    
    for(NSDate *temp in self.wakeScheduleArray){
        NSLog(@"wake: %@", temp);
    }
    
}


@end
