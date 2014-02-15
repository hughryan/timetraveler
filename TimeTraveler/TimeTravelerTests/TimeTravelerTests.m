//
//  TimeTravelerTests.m
//  TimeTravelerTests
//
//  Created by Hugh McDonald on 2/2/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TripDetails.h"

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

- (void)testBasicTrip
{
    TripDetails *testTrip = [[TripDetails alloc] init];
    
    [testTrip setDestinationLocation:@"UTC +5"];
    
    NSDate *testDepartureDate = [[NSDate init] initWithString:@"2014-04-16 10:00:00 +0000"];
    [testTrip setDepartureDate:testDepartureDate];
    
    //XCTAssertEqualObjects(testTrip.departureDate, testDepartureDate, @"Departure Date doesn't match");
    //XCTAssertEqualObjects(testTrip.destinationLocation, @"UTC +5", @"Destination Location doesn't match");
    
}

@end
