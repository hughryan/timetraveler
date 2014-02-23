//
//  TimeTravelerTests.m
//  TimeTravelerTests
//
//  Created by Hugh McDonald on 2/2/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TimeTravelerSettingsViewController.h"

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


//integration test for saving trip data at once
- (void)testBasicTrip
{
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


@end