//
//  TimeTravelerSettingsTableViewController.h
//  TimeTraveler
//
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeTravelerModel.h"

@interface TimeTravelerSettingsViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) TimeTravelerModel *model;

@end
