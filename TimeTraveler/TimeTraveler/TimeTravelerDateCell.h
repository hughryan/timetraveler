//
//  TimeTravelerDateCell.h
//  TimeTraveler
//
//  Created by Hugh McDonald on 3/8/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeTravelerDateCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *wakeTime;
@property (weak, nonatomic) IBOutlet UILabel *sleepTime;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
