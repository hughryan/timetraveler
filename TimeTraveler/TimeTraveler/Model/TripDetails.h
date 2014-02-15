//
//  TripDetails.h
//  TimeTraveler
//
//  Created by Production on 2/14/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TripDetails : NSManagedObject

@property (nonatomic, retain) NSDate * departureDate;
@property (nonatomic, retain) NSDate * sleepTime;
@property (nonatomic, retain) NSDate * wakeTime;
@property (nonatomic, retain) NSString * destinationLocation;
@property (nonatomic, retain) NSNumber * notificationsFlag;

@end
