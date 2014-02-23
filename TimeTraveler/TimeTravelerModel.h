//
//  TimeTravelerModel.h
//  TimeTraveler
//
//  Created by Sean P McDonald on 2/21/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeTravelerModel : NSObject

@property NSUserDefaults *tripSettings;
@property (strong, nonatomic) NSTimeZone *currentTimeZone;
@property (strong, nonatomic) NSString *selectedLocation;
@property (strong, nonatomic) NSNumber *selectedLocationRow;
@property (strong, nonatomic) NSDate *selectedDepartureDate;
@property (strong, nonatomic) NSDate *selectedSleepTime;
@property (strong, nonatomic) NSDate *selectedWakeTime;
@property (strong, nonatomic) NSNumber *selectedNotifications;


-(id)init;

-(void) saved;


@end
