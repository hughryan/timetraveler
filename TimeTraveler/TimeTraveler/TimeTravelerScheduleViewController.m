//
//  TimeTravelerScheduleViewController.m
//  TimeTraveler
//
//  Created by Hugh McDonald on 2/6/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import "TimeTravelerScheduleViewController.h"
#import "SWRevealViewController.h"
#import "TimeTravelerModel.h"
#import "TimeTravelerDateCell.h"

@interface TimeTravelerScheduleViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;

@property (nonatomic) NSTimeInterval timeTillDeparture;
@property (nonatomic) NSTimeInterval secInDay;
@property (nonatomic) NSTimeInterval secondsPassedToday;
@property (nonatomic) BOOL activeTrip;

@property (strong, retain) NSDateFormatter *dateFormatter;
@property (strong, retain) NSDateFormatter *timeFormatter;

@end

@implementation TimeTravelerScheduleViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.settingsButton.target = self.revealViewController;
    self.settingsButton.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    self.model = [[TimeTravelerModel alloc] init];
    [self determineTimeTillDeparture];
    
    // Set up listener for settings changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTable:)
                                                 name:@"settingsChanged"
                                               object:nil];
    
    //NAV BAR
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
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController setNeedsStatusBarAppearanceUpdate];

    
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"moon.jpg"] forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController setNeedsStatusBarAppearanceUpdate];
    
    // Get our custom nav bar
    //self.navBar = (TimeTravelerNavBar*)self.navigationController.navigationBar;
    
    // Set the nav bar's background
    //[self.navBar setBackgroundWith:[UIImage imageNamed:@"moon.jpg"]];
    // Create a custom back button
    //UIButton* backButton = [customNavigationBar backButtonWith:[UIImage imageNamed:@"navigationBarBackButton.png"] highlight:nil leftCapWidth:14.0];
    //backButton.titleLabel.textColor = [UIColor colorWithRed:254.0/255.0 green:239.0/255.0 blue:218.0/225.0 alpha:1];
    //self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];

}


- (void)viewWillAppear:(BOOL)animated
{
    //Refresh Data
    [self.model update];
    [self.model generateSchedule];
    [self determineTimeTillDeparture];
    [self updateBgImage];
    //[self updateNowView];
}


- (void)reloadTable:(NSNotification *)notif {
    [self.model update];
    [self.model generateSchedule];
    [self updateBgImage];
    //[self.tableView reloadData];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

}


- (void)determineTimeTillDeparture {
    
    NSDate *today = [NSDate date];
    
    NSDate *zeroHour = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: zeroHour];
    [components setHour: 00];
    [components setMinute: 00];
    [components setSecond: 00];
    zeroHour = [gregorian dateFromComponents: components];
    
    self.secInDay = 86400;
    self.timeTillDeparture = [self.model.selectedDepartureDate timeIntervalSinceNow];
    self.secondsPassedToday = [today timeIntervalSinceDate:zeroHour];
    
}


-(void)updateBgImage
{
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *wakeComponent;
    NSDateComponents *sleepComponent;
    
    NSDate *awake;
    NSDate *asleep;
    
    NSDate *today = [NSDate date];
    for( NSDate *tempDate in self.model.wakeScheduleArray){
       
        if([today isEqualToDate:tempDate]) {
            //wakeComponent = [cal components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate: tempDate];
            awake = tempDate;
            break;
        }
    }
    
    //awake = [cal dateFromComponents:wakeComponent];
    
    for(NSDate *tempDate in self.model.sleepScheduleArray){
        
        if([today isEqualToDate:tempDate]) {
            
            //sleepComponent = [cal components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate: tempDate];
            //asleep = [cal dateFromComponents:sleepComponent];
            asleep = tempDate;
            break;
            
        }
    }

    
    if(([awake timeIntervalSinceNow] < 0 ) || [asleep timeIntervalSinceNow] >= 0){
     //sleepy time
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"moon.jpg"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController setNeedsStatusBarAppearanceUpdate];
        
        //UIImage *theImage = [UIImage imageNamed:@"moon.jpg"];
        //cell.nowImage.image = theImage;
        //cell.nowLabel.text = @"TEST";
        //self.nowImage.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:moon ofType:@"jpg"]];
        //self.nowLabel.text = @"Rest";

    }else{
        //wakey wakey
     [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"sun.jpg"] forBarMetrics:UIBarMetricsDefault];
     [self.navigationController setNeedsStatusBarAppearanceUpdate];
        
        //UIImage *theImage = [UIImage imageWithContentsOfFile:@"sun.jpg"];
        //cell.imageView.image = theImage;
        //self.nowImage.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:sun ofType:@"jpg"]];
        //self.nowLabel.text = @"Active";
        
    }
    
    //return cell;
    
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
    NSInteger numOfSections = 1;
    //numOfSections += [self.model.wakeScheduleArray count];
    return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numOfRows = [self.model.wakeScheduleArray count];
    return numOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    
    TimeTravelerDateCell *cell;
    
    //check if departure date is tomorrow or greater
    /*
    if (self.timeTillDeparture > (self.secInDay - self.secondsPassedToday)) { //if so update the tables
    
        [self.model generateSchedule:(long)self.timeTillDeparture];
        //if first section load now view
        if (indexPath.section == 0) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"nowViewID"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"nowViewID"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [self updateNowView];
            
        } else { //else load date views
            
            
            
        }
        
    } else {  //if not load 'no schedule set' view
        
        if (indexPath.section == 0) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"nilViewID"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"nilViewID"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
        
    }*/
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"dateCellID"];
    if (cell == nil) {
            cell = [[TimeTravelerDateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dateCellID"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    
    // Create formatters
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle: NSDateFormatterLongStyle];
    [self.dateFormatter setTimeStyle: NSDateFormatterNoStyle];
    
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateStyle: NSDateFormatterNoStyle];
    [self.timeFormatter setTimeStyle: NSDateFormatterShortStyle];
    
    // Format strings
    NSString *formattedDateString = [self.dateFormatter stringFromDate:[self.model.wakeScheduleArray objectAtIndex:indexPath.row]];
    cell.dateLabel.text = formattedDateString;
    NSString *formattedWakeTime = [self.timeFormatter stringFromDate:[self.model.wakeScheduleArray objectAtIndex:indexPath.row]];
    cell.wakeTime.text = formattedWakeTime;
    NSString *formattedSleepTime = [self.timeFormatter stringFromDate:[self.model.sleepScheduleArray objectAtIndex:indexPath.row]];
    cell.sleepTime.text = formattedSleepTime;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 70;
    return rowHeight;
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
