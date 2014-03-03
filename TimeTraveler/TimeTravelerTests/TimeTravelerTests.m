//
//  TimeTravelerTests.m
//  TimeTravelerTests
//
//  Created by Hugh McDonald on 2/2/14.
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


//integration test for saving trip data at once
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

- (void)testTimeZone
{
    NSTimeZone *tempTimeZone = [NSTimeZone localTimeZone];
    XCTAssertNotNil(tempTimeZone);
}


- (void) testDeparture
{
    NSTimeZone *tempTimeZone = [NSTimeZone localTimeZone];
    XCTAssertNotNil(tempTimeZone);
}

- (void)testSleep
{
    NSUserDefaults *tripSettings = [[NSUserDefaults alloc] init];
    NSDate *tempSleepTime = [tripSettings objectForKey:@"sleepTime"];
    XCTAssertNotNil(tempSleepTime, @"Basic trip has Failed");
}

- (void)testWake
{
    NSUserDefaults *tripSettings = [[NSUserDefaults alloc] init];
    NSDate *tempWakeTime = [tripSettings objectForKey:@"wakeTime"];
    XCTAssertNotNil(tempWakeTime, @"Wake test Failed");
}

- (void)testNotificationsButton
{
    NSUserDefaults *tripSettings = [[NSUserDefaults alloc] init];
    NSNumber *tempNotification = [tripSettings objectForKey:@"notifications"];
    XCTAssertNotNil(tempNotification, @"Notifications has failed");
}

- (void) goingEastLessThanTwelve
{
    NSUserDefaults * tripSettings = [[NSUserDefaults alloc] init];
    long result = 0;
    //result = TimeTravelerModel.CalculateTimeZoneDifference;
}

- (void) goingEastGreaterThanOrEqualTwelve
{
    
}

- (void) goingWestLessThanTwelve
{
    
}

- (void) goingWestGreaterThanOrEqualTwelve
{
}


@end