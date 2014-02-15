//
//  TimeTravelerTripDetails.h
//  TimeTraveler
//
//  Created by Hugh McDonald on 2/15/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TimeTravelerTripDetails : NSManagedObject

@property (nonatomic, retain) NSString *destinationLocation;
@property (nonatomic, retain) NSDate *departureDate;
@property (nonatomic, retain) NSDate *wakeTime;
@property (nonatomic, retain) NSDate *sleepTime;
@property (nonatomic, retain) NSNumber *notificationsSetting;

@end
