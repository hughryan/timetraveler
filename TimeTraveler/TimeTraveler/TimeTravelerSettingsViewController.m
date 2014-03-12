//
//  TimeTravelerSettingsTableViewController.m
//  TimeTraveler
//
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import "TimeTravelerSettingsViewController.h"
#import "SWRevealViewController.h"

#define kPickerCellHeight 200

#define kLocationPickerIndex 1
#define kDatePickerIndex 3

#define kSleepPickerIndex 1
#define kWakePickerIndex 3

#define kLocationListDefaultIndex 11

@interface TimeTravelerSettingsViewController ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;

@property (strong, nonatomic) NSArray *locationList;

@property (assign) BOOL locationPickerIsShowing;
@property (assign) BOOL departureDatePickerIsShowing;
@property (assign) BOOL sleepTimePickerIsShowing;
@property (assign) BOOL wakeTimePickerIsShowing;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *locationPicker;
@property (weak, nonatomic) IBOutlet UITableViewCell *locationPickerCell;

@property (weak, nonatomic) IBOutlet UILabel *departureDateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *departureDatePicker;
@property (weak, nonatomic) IBOutlet UITableViewCell *departureDatePickerCell;

@property (weak, nonatomic) IBOutlet UILabel *sleepTimeLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *sleepTimePicker;
@property (weak, nonatomic) IBOutlet UITableViewCell *sleepTimePickerCell;

@property (weak, nonatomic) IBOutlet UILabel *wakeTimeLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *wakeTimePicker;
@property (weak, nonatomic) IBOutlet UITableViewCell *wakeTimePickerCell;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UISwitch *notificationsSwitch;

@end

@implementation TimeTravelerSettingsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.locationList = [[NSArray alloc] initWithObjects:@"GMT-11:00",@"GMT-10:00", @"GMT-09:00", @"GMT-08:00", @"GMT-07:00", @"GMT-06:00", @"GMT-05:00", @"GMT-04:00", @"GMT-03:00", @"GMT-02:00", @"GMT-01:00", @"GMT+00:00", @"GMT+01:00", @"GMT+02:00", @"GMT+03:00", @"GMT+04:00", @"GMT+05:00", @"GMT+06:00", @"GMT+07:00", @"GMT+08:00", @"GMT+09:00", @"GMT+10:00", @"GMT+11:00", @"GMT+12:00", nil];
    
    self.model = [[TimeTravelerModel alloc] init];
    
    [self refreshSettings];
    [self hideLocationPickerCell];
    [self hideDepatureDatePickerCell];
    [self hideWakeTimePickerCell];
    [self hideSleepTimePickerCell];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [self refreshSettings];
    [self closeOtherPickerCells];
}


- (void)refreshSettings
{
    [self.model update];
    [self setupLocationLabel];
    [self setupDepartureDateLabel];
    [self setupSleepLabel];
    [self setupWakeLabel];
    [self setupNotifications];
}


- (void)setupNotifications
{
    if (self.model.selectedNotifications == nil) {
        self.model.selectedNotifications = [NSNumber numberWithUnsignedInteger:1];
    }
    self.notificationsSwitch.On = [self.model.selectedNotifications boolValue];
}


- (void)setupLocationLabel
{
    long currentTimeZoneAdjusted = (([self.model.startingTimeZone secondsFromGMT]) / 3600);
    
    NSNumber *tempRow = self.model.selectedLocationRow;
    
    NSNumber *locationRow = [NSNumber numberWithInt:((int)currentTimeZoneAdjusted + kLocationListDefaultIndex)];
    if (tempRow != nil) locationRow = tempRow;
    
    NSInteger defaultLocationRow = [locationRow intValue];
    
    [self.locationPicker selectRow:defaultLocationRow inComponent:0 animated:NO];
    
    self.locationLabel.text = [self.locationList objectAtIndex:defaultLocationRow];
    
    self.model.selectedLocation = [self.locationList objectAtIndex:defaultLocationRow];
}


- (void)setupDepartureDateLabel
{
    NSDate *tempDepartureDate = self.model.selectedDepartureDate;
    
    NSDate *defaultDepartureDate = [NSDate date];
    if (tempDepartureDate != nil && [tempDepartureDate timeIntervalSinceNow] > 0) defaultDepartureDate = tempDepartureDate;
    
    self.departureDateLabel.text = [self.dateFormatter stringFromDate:defaultDepartureDate];
    
    self.model.selectedDepartureDate = defaultDepartureDate;
    self.departureDatePicker.date = defaultDepartureDate;
}


- (void)setupSleepLabel
{
    NSDate *tempSleepTime = self.model.selectedSleepTime;
    
    NSDate *defaultSleepTime = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: defaultSleepTime];
    [components setHour: 22];
    [components setMinute: 00];
    [components setSecond: 00];
    defaultSleepTime = [gregorian dateFromComponents: components];
    
    if (tempSleepTime != nil) defaultSleepTime = tempSleepTime;
    
    self.sleepTimeLabel.text = [self.timeFormatter stringFromDate:defaultSleepTime];
    
    self.model.selectedSleepTime = defaultSleepTime;
    self.sleepTimePicker.date = defaultSleepTime;
}


- (void)setupWakeLabel
{
    NSDate *tempWakeTime = self.model.selectedWakeTime;
    
    NSDate *defaultWakeTime = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: defaultWakeTime];
    [components setHour: 8];
    [components setMinute: 00];
    [components setSecond: 00];
    defaultWakeTime = [gregorian dateFromComponents: components];
    
    if (tempWakeTime != nil) defaultWakeTime = tempWakeTime;
    
    self.wakeTimeLabel.text = [self.timeFormatter stringFromDate:defaultWakeTime];
    
    self.model.selectedWakeTime = defaultWakeTime;
    self.wakeTimePicker.date = defaultWakeTime;
}


#pragma mark - Picker view methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return [self.locationList count];
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.locationList objectAtIndex:row];
    
}


#pragma mark - Table view methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.tableView.rowHeight;
    
    if (indexPath.section == 0 && indexPath.row == kDatePickerIndex) {
        
        height = self.departureDatePickerIsShowing ? kPickerCellHeight : 0.0f;
        
    } else if (indexPath.section == 0 && indexPath.row == kLocationPickerIndex) {
        
        height = self.locationPickerIsShowing ? kPickerCellHeight : 0.0f;
        
    } else if (indexPath.section == 1 && indexPath.row == kSleepPickerIndex) {
     
        height = self.sleepTimePickerIsShowing ? kPickerCellHeight : 0.0f;
        
    } else if (indexPath.section == 1 && indexPath.row == kWakePickerIndex) {
        
        height = self.wakeTimePickerIsShowing ? kPickerCellHeight : 0.0f;
    }
    
    return height;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        if (self.locationPickerIsShowing){
            
            [self hideLocationPickerCell];
            
        } else {
            
            [self showLocationPickerCell];
    
        }
        
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        
        if (self.departureDatePickerIsShowing){
            
            [self hideDepatureDatePickerCell];
            
        } else {
            
            [self showDepartureDatePickerCell];
            
        }

    } else if (indexPath.section == 1 && indexPath.row == 0) {
        
        if (self.sleepTimePickerIsShowing) {
            
            [self hideSleepTimePickerCell];
            
        } else {
            
            [self showSleepTimePickerCell];
            
        }
        
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        
        if (self.wakeTimePickerIsShowing) {
            
            [self hideWakeTimePickerCell];
            
        } else {
            
            [self showWakeTimePickerCell];
            
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)showDepartureDatePickerCell
{
    [self closeOtherPickerCells];
    self.departureDatePickerIsShowing = YES;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.departureDatePicker.hidden = NO;
    self.departureDatePicker.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.departureDatePicker.alpha = 1.0f;
        
    }];
    
    self.departureDateLabel.textColor = [self.tableView tintColor];
}


- (void)hideDepatureDatePickerCell
{
    self.departureDatePickerIsShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.departureDatePicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.departureDatePicker.hidden = YES;
                     }];
    
    self.departureDateLabel.textColor = [UIColor blackColor];
}


- (void)showLocationPickerCell
{
    [self closeOtherPickerCells];
    self.locationPickerIsShowing = YES;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.locationPicker.hidden = NO;
    self.locationPicker.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.locationPicker.alpha = 1.0f;
        
    }];
    

    self.locationLabel.textColor = [self.tableView tintColor];
}


- (void)hideLocationPickerCell
{
    self.locationPickerIsShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.locationPicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.locationPicker.hidden = YES;
                     }];
    
    self.locationLabel.textColor = [UIColor blackColor];
}


- (void)showSleepTimePickerCell
{
    [self closeOtherPickerCells];
    self.sleepTimePickerIsShowing = YES;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.sleepTimePicker.hidden = NO;
    self.sleepTimePicker.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.sleepTimePicker.alpha = 1.0f;
        
    }];
    
    self.sleepTimeLabel.textColor = [self.tableView tintColor];
}


- (void)hideSleepTimePickerCell
{
    self.sleepTimePickerIsShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.sleepTimePicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.sleepTimePicker.hidden = YES;
                     }];

    self.sleepTimeLabel.textColor = [UIColor blackColor];
}


- (void)showWakeTimePickerCell
{
    [self closeOtherPickerCells];
    self.wakeTimePickerIsShowing = YES;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.wakeTimePicker.hidden = NO;
    self.wakeTimePicker.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.wakeTimePicker.alpha = 1.0f;
        
    }];
    
    self.wakeTimeLabel.textColor = [self.tableView tintColor];
}


- (void)hideWakeTimePickerCell
{
    self.wakeTimePickerIsShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.wakeTimePicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.wakeTimePicker.hidden = YES;
                     }];
    
    self.wakeTimeLabel.textColor = [UIColor blackColor];
}


- (void)closeOtherPickerCells
{
    if (self.locationPickerIsShowing) {
        [self hideLocationPickerCell];
    }
    if (self.departureDatePickerIsShowing) {
        [self hideDepatureDatePickerCell];
    }
    if (self.sleepTimePickerIsShowing) {
        [self hideSleepTimePickerCell];
    }
    if (self.wakeTimePickerIsShowing) {
        [self hideWakeTimePickerCell];
    }
}


#pragma mark - Action methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.locationLabel.text = [self.locationList objectAtIndex:row];
    
    self.model.selectedLocationRow = [NSNumber numberWithInteger:(NSInteger)row];
    self.model.selectedLocation = [self.locationList objectAtIndex:row];
    NSLog(@"Location: %@", self.model.selectedLocation);
}


- (IBAction)departureDatePickerChanged:(UIDatePicker *)sender
{
    if ([sender.date timeIntervalSinceNow] < 0) {
        sender.date = [NSDate date];
    }
    
    self.departureDateLabel.text =  [self.dateFormatter stringFromDate:sender.date];
    
    self.model.selectedDepartureDate = sender.date;
    NSLog(@"Departure Date: %@", self.model.selectedDepartureDate);
}


- (IBAction)sleepTimePickerChanged:(UIDatePicker *)sender
{
    self.sleepTimeLabel.text =  [self.timeFormatter stringFromDate:sender.date];
    
    self.model.selectedSleepTime = sender.date;
    NSLog(@"Sleep Time: %@", self.model.selectedSleepTime);
}


- (IBAction)wakeTimePickerChanged:(UIDatePicker *)sender
{
    self.wakeTimeLabel.text =  [self.timeFormatter stringFromDate:sender.date];
    
    self.model.selectedWakeTime = sender.date;
    NSLog(@"Wake Time: %@", self.model.selectedWakeTime);
}


- (IBAction)notificationsSwitchChanged:(UISwitch *)sender
{
    self.model.selectedNotifications = [NSNumber numberWithBool:sender.on];
    NSLog(@"Notifications: %d", [self.model.selectedNotifications boolValue]);
}


- (IBAction)saveButtonPushed:(UIButton *)sender
{
    NSLog(@"=========Save Button Pushed=========");
    
    [self.model save];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsChanged"
                                                        object:nil];
    [self.revealViewController revealToggleAnimated:YES];
    
}

- (IBAction)resetButtonPushed:(UIButton *)sender
{
    NSLog(@">>>>>>>>>Reset Button Pushed<<<<<<<<<<");
    UIAlertView *confirmation = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Reset Trip Settings", nil)
                                                           message:NSLocalizedString(@"Are you sure you want to reset the last saved trip?", nil)
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 otherButtonTitles:NSLocalizedString(@"Reset", nil), nil];
    [confirmation show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
            
        case 0:
        {
            NSLog(@"Reset cancelled by user.");
        }
        break;
            
        case 1:
        {
            // Reset confirmed clearing data
            [self.model reset];
            [self refreshSettings];
            [self closeOtherPickerCells];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsChanged"
                                                                object:nil];
            [self.revealViewController revealToggleAnimated:YES];
        }
        break;
    }
}


@end
