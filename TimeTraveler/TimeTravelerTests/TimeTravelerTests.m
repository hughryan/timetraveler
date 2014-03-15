//
//  TimeTravelerTests.m
//  TimeTravelerTests
//
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TimeTravelerSettingsViewController.h"
#import "TimeTravelerModel.h"

@interface TimeTravelerTests : XCTestCase

@end

@implementation TimeTravelerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

void setData()
{
    TimeTravelerModel *ttm;
    
    NSDate *currDate = [NSDate date];
    NSNumber *notifications =@(1);
    NSDate *currSleepTime = [NSDate date];
    NSDate *deptDate = [NSDate date];
    
    ttm.selectedWakeTime = currDate;
    ttm.selectedNotifications = notifications;
    ttm.selectedSleepTime = currSleepTime;
    ttm.selectedDepartureDate = deptDate;
    
    [ttm save];
}


//integration test for saving all trip data at once
- (void)testBasicTrip
{
    setData();
    NSUserDefaults *tripSettings = [[NSUserDefaults alloc] init];
    
    NSDate *tempDepDay = [tripSettings objectForKey:@"departureDate"];
    NSDate *tempSleepTime = [tripSettings objectForKey:@"sleepTime"];
    NSDate *tempWakeTime = [tripSettings objectForKey:@"wakeTime"];
    NSNumber *tempNotification = [tripSettings objectForKey:@"notifications"];
    NSTimeZone *tempTimeZone = [NSTimeZone localTimeZone];
    
    XCTAssertNotNil(tempTimeZone);
    XCTAssertNotNil(tempDepDay);
    XCTAssertNotNil(tempSleepTime);
    XCTAssertNotNil(tempWakeTime);
    XCTAssertNotNil(tempNotification);
}

//Following tests are for saving trip data

//Unit test for saving time zone to travel to.
- (void)testArrivalTimeZone
{
    NSTimeZone *tempTimeZone = [NSTimeZone localTimeZone];
    XCTAssertNotNil(tempTimeZone, @"Arrival time zone test failed");
}

//Test for saving current timezone
- (void) testDepartureTimeZone
{
    NSTimeZone *tempTimeZone = [NSTimeZone localTimeZone];
    XCTAssertNotNil(tempTimeZone, @"Departure time zone test failed");
}

//Saving normal sleep time test
- (void)testSleep
{
    NSUserDefaults *tripSettings = [[NSUserDefaults alloc] init];
    NSDate *tempSleepTime = [tripSettings objectForKey:@"sleepTime"];
    XCTAssertNotNil(tempSleepTime, @"Sleep time test failed");
}

//Saving normal wake time test
- (void)testWake
{
    NSUserDefaults *tripSettings = [[NSUserDefaults alloc] init];
    NSDate *tempWakeTime = [tripSettings objectForKey:@"wakeTime"];
    XCTAssertNotNil(tempWakeTime, @"Wake test Failed");
}

//Test notifications boolean
- (void)testNotificationsButton
{
    NSUserDefaults *tripSettings = [[NSUserDefaults alloc] init];
    NSNumber *tempNotification = [tripSettings objectForKey:@"notifications"];
    XCTAssertNotNil(tempNotification, @"Notifications test has failed");
}


//The following tests are edge cases for our algorithm

//Test sub-hemisphere Eastern travel
- (void)testGoingEastLessThanTwelve
{
    
    TimeTravelerModel * model = [[TimeTravelerModel alloc] init];
    model.selectedLocation = @"-4";
    [model generateSchedule];
     XCTAssertNotNil(model.wakeScheduleArray, @"Going east < 12 failure");
    
}

//Test sub-hemisphere western travel
- (void)testGoingWestLessThanTwelve
{
    TimeTravelerModel * model = [[TimeTravelerModel alloc] init];
    model.selectedLocation = @"-10";
    [model generateSchedule];
    XCTAssertNotNil(model.wakeScheduleArray, @"Going West < 12 failure");
}

//test 12 hour trips algorithm is correct
- (void)testGoingTwelve
{
    
    TimeTravelerModel * model = [[TimeTravelerModel alloc] init];
    model.selectedLocation = @"8";
    [model generateSchedule];
    XCTAssertNotNil(model.wakeScheduleArray, @"Going East / West > 12 failure");
}


@end