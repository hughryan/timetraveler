//
//  TimeTravelerModel.h
//  TimeTraveler
//
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeTravelerModel : NSObject

@property (strong, nonatomic) NSTimeZone *startingTimeZone;
@property (strong, nonatomic) NSString *selectedLocation;
@property (strong, nonatomic) NSNumber *selectedLocationRow;
@property (strong, nonatomic) NSDate *selectedDepartureDate;
@property (strong, nonatomic) NSDate *selectedSleepTime;
@property (strong, nonatomic) NSDate *selectedWakeTime;
@property (strong, nonatomic) NSNumber *selectedNotifications;
@property (strong, nonatomic) NSDate *startDate;

@property (nonatomic) NSTimeInterval timeTillDeparture;
@property (nonatomic) NSTimeInterval secInDay;
@property (nonatomic) NSTimeInterval secondsPassedToday;

@property (strong, nonatomic) NSMutableArray *wakeScheduleArray;
@property (strong, nonatomic) NSMutableArray *sleepScheduleArray;

- (id)init;
- (void)update;
- (void)save;
- (void)generateSchedule;
- (void)determineTimeTillDeparture;

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

@end
