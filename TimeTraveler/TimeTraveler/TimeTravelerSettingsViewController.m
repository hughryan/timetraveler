//
//  TimeTravelerSettingsTableViewController.m
//  TimeTraveler
//
//  Created by Hugh McDonald on 2/3/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import "TimeTravelerSettingsViewController.h"

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
@property (weak, nonatomic) IBOutlet UISwitch *notificationsSwitch;

@end

@implementation TimeTravelerSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.locationList = [[NSArray alloc] initWithObjects:@"UTC -11",@"UTC -10", @"UTC -9", @"UTC -8", @"UTC -7", @"UTC -6", @"UTC -5", @"UTC -4", @"UTC -3", @"UTC -2", @"UTC -1", @"UTC +0", @"UTC +1", @"UTC +2", @"UTC +3", @"UTC +4", @"UTC +5", @"UTC +6", @"UTC +7", @"UTC +8", @"UTC +9", @"UTC +10", @"UTC +11", @"UTC +12", nil];
    
    [self setupLocationLabel];
    [self setupDepartureDateLabel];
    [self setupSleepLabel];
    [self setupWakeLabel];
    [self setupNotifications];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self closeOtherPickerCells];
    [self setupLocationLabel];
    [self setupDepartureDateLabel];
    [self setupSleepLabel];
    [self setupWakeLabel];
    [self setupNotifications];
}

- (void)setupNotifications
{
    NSUserDefaults *tripSettings = [NSUserDefaults standardUserDefaults];
    NSNumber *notifications = [tripSettings objectForKey:@"notifications"];
    self.notificationsSwitch.On = [notifications boolValue];
}

- (void)setupLocationLabel
{
    NSUserDefaults *tripSettings = [NSUserDefaults standardUserDefaults];
    NSNumber *tempRow = [tripSettings objectForKey:@"destinationLocationRow"];
    
    NSNumber *locationRow = [NSNumber numberWithInt:kLocationListDefaultIndex];
    if (tempRow != nil) locationRow = tempRow;
    
    NSInteger defaultLocationRow = [locationRow intValue];
    
    [self.locationPicker selectRow:defaultLocationRow inComponent:0 animated:NO];
    
    self.locationLabel.text = [self.locationList objectAtIndex:defaultLocationRow];
    self.locationLabel.textColor = [self.tableView tintColor];
    
    self.selectedLocation = [self.locationList objectAtIndex:defaultLocationRow];
}

- (void)setupDepartureDateLabel
{
    NSUserDefaults *tripSettings = [NSUserDefaults standardUserDefaults];
    NSDate *tempDepartureDate = [tripSettings objectForKey:@"departureDate"];
    
    NSDate *defaultDepartureDate = [NSDate date];
    if (tempDepartureDate != nil && [tempDepartureDate timeIntervalSinceNow] > 0) defaultDepartureDate = tempDepartureDate;
    
    self.departureDateLabel.text = [self.dateFormatter stringFromDate:defaultDepartureDate];
    self.departureDateLabel.textColor = [self.tableView tintColor];
    
    self.selectedDepartureDate = defaultDepartureDate;
    self.departureDatePicker.date = defaultDepartureDate;
}

- (void)setupSleepLabel
{
    NSUserDefaults *tripSettings = [NSUserDefaults standardUserDefaults];
    NSDate *tempSleepTime = [tripSettings objectForKey:@"sleepTime"];
    
    NSDate *defaultSleepTime = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: defaultSleepTime];
    [components setHour: 22];
    [components setMinute: 00];
    [components setSecond: 00];
    defaultSleepTime = [gregorian dateFromComponents: components];
    
    if (tempSleepTime != nil) defaultSleepTime = tempSleepTime;
    
    self.sleepTimeLabel.text = [self.timeFormatter stringFromDate:defaultSleepTime];
    self.sleepTimeLabel.textColor = [self.tableView tintColor];
    
    self.selectedSleepTime = defaultSleepTime;
    self.sleepTimePicker.date = defaultSleepTime;
}

- (void)setupWakeLabel
{
    NSUserDefaults *tripSettings = [NSUserDefaults standardUserDefaults];
    NSDate *tempWakeTime = [tripSettings objectForKey:@"wakeTime"];
    
    NSDate *defaultWakeTime = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: defaultWakeTime];
    [components setHour: 8];
    [components setMinute: 00];
    [components setSecond: 00];
    defaultWakeTime = [gregorian dateFromComponents: components];
    
    if (tempWakeTime != nil) defaultWakeTime = tempWakeTime;
    
    self.wakeTimeLabel.text = [self.timeFormatter stringFromDate:defaultWakeTime];
    self.wakeTimeLabel.textColor = [self.tableView tintColor];
    
    self.selectedWakeTime = defaultWakeTime;
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
    
    self.selectedLocationRow = [NSNumber numberWithInteger:(NSInteger)row];
    self.selectedLocation = [self.locationList objectAtIndex:row];
    NSLog(@"Location: %@", self.selectedLocation);
}

- (IBAction)departureDatePickerChanged:(UIDatePicker *)sender
{
    
    if ([sender.date timeIntervalSinceNow] < 0) {
        sender.date = [NSDate date];
    }
    
    self.departureDateLabel.text =  [self.dateFormatter stringFromDate:sender.date];
    
    self.selectedDepartureDate = sender.date;
    NSLog(@"Departure Date: %@", self.selectedDepartureDate);
}

- (IBAction)sleepTimePickerChanged:(UIDatePicker *)sender
{
    
    self.sleepTimeLabel.text =  [self.timeFormatter stringFromDate:sender.date];
    
    self.selectedSleepTime = sender.date;
    NSLog(@"Sleep Time: %@", self.selectedSleepTime);
}

- (IBAction)wakeTimePickerChanged:(UIDatePicker *)sender
{
    
    self.wakeTimeLabel.text =  [self.timeFormatter stringFromDate:sender.date];
    
    self.selectedWakeTime = sender.date;
    NSLog(@"Wake Time: %@", self.selectedWakeTime);
}

- (IBAction)notificationsSwitchChanged:(UISwitch *)sender
{
    
    self.selectedNotifications = [NSNumber numberWithBool:sender.on];
    NSLog(@"Notifications: %d", [self.selectedNotifications boolValue]);
    
}

- (IBAction)saveButtonPushed:(UIButton *)sender
{
    NSLog(@"Save Button Pushed");
    NSUserDefaults *tripSettings = [NSUserDefaults standardUserDefaults];
    [tripSettings setObject:self.selectedLocation forKey:@"destinationLocation"];
    [tripSettings setObject:self.selectedLocationRow forKey:@"destinationLocationRow"];
    [tripSettings setObject:self.selectedDepartureDate forKey:@"departureDate"];
    [tripSettings setObject:self.selectedSleepTime forKey:@"sleepTime"];
    [tripSettings setObject:self.selectedWakeTime forKey:@"wakeTime"];
    [tripSettings setObject:self.selectedNotifications forKey:@"notifications"];
    [tripSettings synchronize];
}


#pragma mark - Xcode methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
