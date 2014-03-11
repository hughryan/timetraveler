//
//  TimeTravelerScheduleViewController.m
//  TimeTraveler
//
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import "TimeTravelerScheduleViewController.h"
#import "SWRevealViewController.h"
#import "TimeTravelerModel.h"
#import "TimeTravelerDateCell.h"

@interface TimeTravelerScheduleViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;

@property (nonatomic) BOOL activeTrip;

@property (strong, retain) NSDateFormatter *dateFormatter;
@property (strong, retain) NSDateFormatter *timeFormatter;

@end

@implementation TimeTravelerScheduleViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up settings controller
    self.settingsButton.target = self.revealViewController;
    self.settingsButton.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    // Set up model
    self.model = [[TimeTravelerModel alloc] init];
    [self.model determineTimeTillDeparture];
    
    // Set up listener for settings changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTable:)
                                                 name:@"settingsChanged"
                                               object:nil];
    
    // Create formatters
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle: NSDateFormatterLongStyle];
    [self.dateFormatter setTimeStyle: NSDateFormatterNoStyle];
    
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateStyle: NSDateFormatterNoStyle];
    [self.timeFormatter setTimeStyle: NSDateFormatterShortStyle];
    
    // Update model
    [self update];
    
    // Navbar logo
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tt_logo.png"]];
    self.navigationItem.titleView = imageView;
    
    // Notifcation that application has reentered foreground
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    // Load timer to update table every minute
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(reloadTable:) userInfo:nil repeats:YES];
    
}


- (void)applicationEnteredForeground:(NSNotification *)notification {
    NSLog(@"Application Entered Foreground");
    [self update];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}


- (void)update
{
    [self.model update];
    [self.model generateSchedule];
    [self checkForActiveTrip];
    NSLog(@"Active Trip: %d", self.activeTrip);
    [self scheduleTripNotifications];
    [self updateBgImage];
}


- (void)checkForActiveTrip
{
    if ([self.model.wakeScheduleArray count] || [self.model.sleepScheduleArray count]) {
        self.activeTrip = YES;
    } else {
        self.activeTrip = NO;
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [self update];
}


- (void)reloadTable:(NSNotification *)notif
{
    [self update];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}


- (NSDateComponents *)breakDateComponents:(NSDate *)dateToBreakApart
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components: (NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:dateToBreakApart];
    return components;
}


- (BOOL)isToday:(NSDate *)checkDate
{
    NSDate *todayDate = [NSDate date];
    NSDateComponents *today = [self breakDateComponents:todayDate];
    NSDateComponents *check = [self breakDateComponents:checkDate];
    if (check.day == today.day && check.month == today.month && check.year == today.year) {
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)isTomorrow:(NSDate *)checkDate
{
    NSDateComponents *check = [self breakDateComponents:checkDate];
    
    NSDate *todayDate = [NSDate date];
    NSDateComponents *today = [self breakDateComponents:todayDate];
    [today setHour: 00];
    [today setMinute: 00];
    [today setSecond: 00];
    todayDate = [[NSCalendar currentCalendar] dateFromComponents: today];
    
    NSDate *tomorrowDate = [todayDate dateByAddingTimeInterval:60*60*24];
    NSDateComponents *tomorrow = [self breakDateComponents:tomorrowDate];
    
    if (check.day == tomorrow.day && check.month == tomorrow.month && check.year == tomorrow.year) {
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)isDeparture:(NSDate *)checkDate
{
    NSDateComponents *check = [self breakDateComponents:checkDate];
    NSDateComponents *departure = [self breakDateComponents:self.model.selectedDepartureDate];
    
    if (check.day == departure.day && check.month == departure.month && check.year == departure.year) {
        return YES;
    } else {
        return NO;
    }
}


-(void)updateBgImage
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"plane.png"] forBarMetrics:UIBarMetricsDefault];
    
    if (self.activeTrip) {
        
        NSDateComponents *wake;
        NSDateComponents *sleep;
        BOOL eventsToday = NO;
        
        NSDate *todayDate = [NSDate date];
        NSDateComponents *today = [self breakDateComponents:todayDate];
        
        NSMutableArray *wakeArray = [NSMutableArray array];
        NSMutableArray *sleepArray = [NSMutableArray array];
        
        // Get future events for today
        for (NSDate *tempDate in self.model.wakeScheduleArray){
            
            //break time in to NSDateComponents
            wake = [self breakDateComponents:tempDate];
            
            if (wake.day == today.day && wake.month == today.month && wake.year == today.year) {
                eventsToday = YES;
                if (wake.hour == today.hour) {
                    if (wake.minute > today.minute) {
                        [wakeArray addObject:wake];
                    }
                } else if (wake.hour > today.hour) {
                    [wakeArray addObject:wake];
                }
            }
        }
    
        for (NSDate *tempDate in self.model.sleepScheduleArray) {
            
            //break time in to NSDateComponents
            sleep = [self breakDateComponents:tempDate];
            
            if (sleep.day == today.day && sleep.month == today.month && sleep.year == today.year) {
                eventsToday = YES;
                if (sleep.hour == today.hour) {
                    if (sleep.minute > today.minute) {
                        [sleepArray addObject:sleep];
                    }
                } else if (sleep.hour > today.hour) {
                    [sleepArray addObject:sleep];
                }
            }
        }
        
        // If no future events for today, get tomorrow's instead
        if (eventsToday && ![wakeArray count] && ![sleepArray count]) {
            
            [today setHour: 00];
            [today setMinute: 00];
            [today setSecond: 00];
            todayDate = [[NSCalendar currentCalendar] dateFromComponents: today];

            NSDate *tomorrowDate = [todayDate dateByAddingTimeInterval:60*60*24];
            NSDateComponents *tomorrow = [self breakDateComponents:tomorrowDate];
            
            for (NSDate *tempDate in self.model.wakeScheduleArray){
                
                //break time in to NSDateComponents
                wake = [self breakDateComponents:tempDate];
                
                if (wake.day == tomorrow.day && wake.month == tomorrow.month && wake.year == tomorrow.year) {
                        [wakeArray addObject:wake];
                }
            }
            
            for (NSDate *tempDate in self.model.sleepScheduleArray){
                
                //break time in to NSDateComponents
                sleep = [self breakDateComponents:tempDate];
                
                if (sleep.day == tomorrow.day && sleep.month == tomorrow.month && sleep.year == tomorrow.year) {
                    [sleepArray addObject:sleep];
                }
            }
            
        }
        
        // Sort array and find the event happening next
        NSString *currentEvent = @"Future";
        NSDateComponents *nextEventTime = [[NSDateComponents alloc] init];
        
        if ([wakeArray count]) {
            
            [nextEventTime setHour:[[wakeArray objectAtIndex:0] hour]];
            [nextEventTime setMinute:[[wakeArray objectAtIndex:0] minute]];
            [nextEventTime setSecond:[[wakeArray objectAtIndex:0] second]];
            currentEvent = @"Sleep";
            
        } else if ([sleepArray count]) {
            
            [nextEventTime setHour:[[sleepArray objectAtIndex:0] hour]];
            [nextEventTime setMinute:[[sleepArray objectAtIndex:0] minute]];
            [nextEventTime setSecond:[[sleepArray objectAtIndex:0] second]];
            currentEvent = @"Wake";
        }
        
        for (NSDateComponents *tempComp in wakeArray) {
            
            if (tempComp.hour < nextEventTime.hour) {
                nextEventTime = tempComp;
                // Next event is wake so current event is sleep
                currentEvent = @"Sleep";
            }
        }
        
        for (NSDateComponents *tempComp in sleepArray) {
           
            if (tempComp.hour < nextEventTime.hour) {
                nextEventTime = tempComp;
                // Next event is sleep so current event is wake
                currentEvent = @"Wake";
            }
        }
        
        NSLog(@"Current Event: %@", currentEvent);
        
        if ([currentEvent isEqual: @"Sleep"]){
            //sleepy time
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"night.png"] forBarMetrics:UIBarMetricsDefault];
        } else if ([currentEvent isEqual:@"Wake"]){
            //wakey wakey
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"day.png"] forBarMetrics:UIBarMetricsDefault];
        } else {
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"plane.png"] forBarMetrics:UIBarMetricsDefault];
        }
    
    }
    
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
}


- (void)scheduleTripNotifications
{
    // Clear all previous notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // If notifications are enabled set them
    if (self.model.selectedNotifications) {
        // Set new notifications
        NSString *message = [[NSString alloc] init];
    
        // Wake notifications
        message = @"wake";
        for (NSDate *event in self.model.wakeScheduleArray) {
            [self scheduleNotification:event withMessage:message];
        }
    
        // Sleep notifications
        message = @"sleep";
        for (NSDate *event in self.model.sleepScheduleArray) {
            [self scheduleNotification:event withMessage:message];
        }
    }
}


- (void)scheduleNotification:(NSDate *)scheduleDate withMessage:(NSString *)notificationMessage
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = scheduleDate;
    notification.timeZone = self.model.startingTimeZone;
    
    if ([notificationMessage isEqualToString:@"wake"]) {
        notification.alertBody = NSLocalizedString(@"Time to wake up. Be active and seek blue light.", nil);
    } else if ([notificationMessage isEqualToString:@"sleep"]) {
        notification.alertBody = NSLocalizedString(@"Time to sleep. Rest and avoid blue light.", nil);
    } else {
        return;
    }
    
    notification.alertAction = NSLocalizedString(@"View Schedule", nil);
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}


#pragma - Xcode Methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger numOfSections = [self.model.wakeScheduleArray count];
    if (numOfSections == 0) {
        numOfSections = 1;
    }
    return numOfSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numOfRows = 1;
    return numOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeTravelerDateCell *cell;
    NSString *celltype = [[NSString alloc] init];
    
    // Check if there is an active trip
    if (self.activeTrip) {
    
        if (indexPath.section == 0 && [self isToday:[self.model.wakeScheduleArray objectAtIndex:indexPath.section]]) {
            celltype = @"todayCellID";
        } else {
            celltype = @"dateCellID";
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:celltype];
        if (cell == nil) {
            cell = [[TimeTravelerDateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celltype];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    
        // Format strings
        NSString *formattedWakeTime = [self.timeFormatter stringFromDate:[self.model.wakeScheduleArray objectAtIndex:indexPath.section]];
        cell.wakeTime.text = formattedWakeTime;
        NSString *formattedSleepTime = [self.timeFormatter stringFromDate:[self.model.sleepScheduleArray objectAtIndex:indexPath.section]];
        cell.sleepTime.text = formattedSleepTime;
    
    } else { // No active trip
        
        celltype = @"nilCellID";
        cell = [tableView dequeueReusableCellWithIdentifier:celltype];
        if (cell == nil) {
            cell = [[TimeTravelerDateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:celltype];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight;
    if (self.activeTrip) {
        if (indexPath.section == 0 && [self isToday:[self.model.wakeScheduleArray objectAtIndex:indexPath.section]]) {
            rowHeight = 100;
        } else {
            rowHeight = 70;
        }
    } else {
        rowHeight = tableView.bounds.size.height;
    }

    return rowHeight;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.selectionStyle == UITableViewCellSelectionStyleNone){
        return nil;
    }
    return indexPath;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = nil;
    
    if (self.activeTrip) {
        
        if ([self isToday:[self.model.wakeScheduleArray objectAtIndex:section]])
        {
            if (section == 0) {
                sectionTitle = NSLocalizedString(@"Today", nil);
            } else {
                sectionTitle = NSLocalizedString(@"Later Today", nil);
            }
            
        } else if ([self isTomorrow:[self.model.wakeScheduleArray objectAtIndex:section]]) {
            
            sectionTitle = NSLocalizedString(@"Tomorrow", nil);

        } else if ([self isDeparture:[self.model.wakeScheduleArray objectAtIndex:section]]) {
            
            sectionTitle = NSLocalizedString(@"Travel Day", nil);
            
        } else {
            
            sectionTitle = [self.dateFormatter stringFromDate:[self.model.wakeScheduleArray objectAtIndex:section]];
        }
    }
    
    return sectionTitle;
}


@end
