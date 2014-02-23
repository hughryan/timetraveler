//
//  TimeTravelerSettingsTableViewController.h
//  TimeTraveler
//
//  Created by Hugh McDonald on 2/3/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeTravelerModel.h"

@interface TimeTravelerSettingsViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) TimeTravelerModel *model;


@end
