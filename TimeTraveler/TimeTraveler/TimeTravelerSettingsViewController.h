//
//  TimeTravelerSettingsTableViewController.h
//  TimeTraveler
//
//  Created by Hugh McDonald on 2/3/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeTravelerSettingsViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSString *selectedLocation;
@property (strong, nonatomic) NSNumber *selectedLocationRow;
@property (strong, nonatomic) NSDate *selectedDepartureDate;
@property (strong, nonatomic) NSDate *selectedSleepTime;
@property (strong, nonatomic) NSDate *selectedWakeTime;
@property (strong, nonatomic) NSNumber *selectedNotifications;

@end
