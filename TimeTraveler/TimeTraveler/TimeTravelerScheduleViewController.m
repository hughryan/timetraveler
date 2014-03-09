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
    
    [self update];
    
    //NAV BAR
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tt_logo.png"]];
    self.navigationItem.titleView = imageView;
    
    /*
    UIImage* titleImage = [UIImage imageNamed:@"moon.jpg"];
    UIView* titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,titleImage.size.width, self.navigationController.navigationBar.frame.size.height)];
    UIImageView* titleImageView = [[UIImageView alloc] initWithImage:titleImage];
    [titleView addSubview:titleImageView];
    titleImageView.center = titleView.center;
    CGRect titleImageViewFrame = titleImageView.frame;
    // Offset the logo up a bit
    titleImageViewFrame.origin.y = titleImageViewFrame.origin.y + 3.0;
    titleImageView.frame = titleImageViewFrame;
    self.navigationItem.titleView = titleView;
     */

}


- (void)update
{
    [self.model update];
    [self.model generateSchedule];
    [self checkForActiveTrip];
    [self updateBgImage];
}


- (void)checkForActiveTrip
{
    if ([self.model.wakeScheduleArray count] || [self.model.sleepScheduleArray count]) {
        self.activeTrip = YES;
    } else {
        self.activeTrip = NO;
    }
    NSLog(@"Active Trip: %d", self.activeTrip);
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


-(void)updateBgImage
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"plane.png"] forBarMetrics:UIBarMetricsDefault];
    
    if (self.activeTrip) {
        
        NSDateComponents *wake;
        NSDateComponents *sleep;
        
        NSDate *todayDate = [NSDate date];
        NSDateComponents *today = [self breakDateComponents:todayDate];
        
        NSMutableArray *wakeArray = [NSMutableArray array];
        NSMutableArray *sleepArray = [NSMutableArray array];
        
        for (NSDate *tempDate in self.model.wakeScheduleArray){
            
            //break time in to NSDateComponents
            wake = [self breakDateComponents:tempDate];
            //NSLog(@"WAKE DAY: %ld", (long)wake.day);
            //NSLog(@"WAKE HOUR: %ld", (long)wake.hour);
            //NSLog(@"TODAY: %ld", (long)today.day);
            //NSLog(@"NOW: %ld", (long)today.hour);
            
            if (wake.day == today.day && wake.month == today.month && wake.year == today.year) {
                if (wake.hour > today.hour) {
                    [wakeArray addObject:wake];
                }
            }
        }
    
        for (NSDate *tempDate in self.model.sleepScheduleArray) {
            
            //break time in to NSDateComponents
            sleep = [self breakDateComponents:tempDate];
            //NSLog(@"SLEEP DAY: %ld", (long)sleep.day);
            //NSLog(@"SLEEP HOUR: %ld", (long)sleep.hour);
            //NSLog(@"TODAY: %ld", (long)today.day);
            //NSLog(@"NOW: %ld", (long)today.hour);
            
            if (sleep.day == today.day && sleep.month == today.month && sleep.year == today.year) {
                if (sleep.hour > today.hour) {
                    [sleepArray addObject:sleep];
                }
            }
        }

        //NSLog(@"Array Size: %ld", [wakeArray count]);
        
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
    //self.activeTrip = YES;
    if (numOfSections == 0) {
        numOfSections = 1;
        //self.activeTrip = NO;
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
    
    // Check if there is an active trip
    if (self.activeTrip) {
    
        cell = [tableView dequeueReusableCellWithIdentifier:@"dateCellID"];
        if (cell == nil) {
                cell = [[TimeTravelerDateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dateCellID"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    
        // Format strings
        NSString *formattedWakeTime = [self.timeFormatter stringFromDate:[self.model.wakeScheduleArray objectAtIndex:indexPath.section]];
        cell.wakeTime.text = formattedWakeTime;
        NSString *formattedSleepTime = [self.timeFormatter stringFromDate:[self.model.sleepScheduleArray objectAtIndex:indexPath.section]];
        cell.sleepTime.text = formattedSleepTime;
    
    } else { // No active trip
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"nilCellID"];
        if (cell == nil) {
            cell = [[TimeTravelerDateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nilCellID"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 70;
    if (!self.activeTrip) rowHeight = tableView.bounds.size.height;
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
        NSDate *todayDate = [NSDate date];
        NSDateComponents *today = [self breakDateComponents:todayDate];
        NSDateComponents *event = [self breakDateComponents:[self.model.wakeScheduleArray objectAtIndex:section]];
        if (event.day == today.day && event.month == today.month && event.year == today.year) {
            sectionTitle = @"Today";
        } else {
            sectionTitle = [self.dateFormatter stringFromDate:[self.model.wakeScheduleArray objectAtIndex:section]];
        }
    }
    return sectionTitle;
}

@end
