//
//  TimeTravelerDataModel.h
//  TimeTraveler
//
//  Created by Hugh McDonald on 2/8/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeTravelerDataModel : NSObject

@property (strong, nonatomic) NSString *selectedLocation;
@property (strong, nonatomic) NSDate *selectedDepartureDate;
@property (strong, nonatomic) NSDate *selectedSleepTime;
@property (strong, nonatomic) NSDate *selectedWakeTime;
@property (nonatomic) BOOL selectedNotifications;

@end
