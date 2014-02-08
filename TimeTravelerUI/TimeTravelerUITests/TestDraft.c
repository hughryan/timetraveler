-(void) testValidInputStorage

-(void) testDiffTimeZones

-(void) testTripDateUpcoming
{
	NSObject *object = [[NSOBject alloc] init];
	XCTAssertTrue(object, @"Banana waffles is true");
}

//
//  Time_TravelerTests.m
//  Time TravelerTests
//
//  Created by Hugh McDonald on 1/24/14.
//  Copyright (c) 2014 snowFish. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface Time_TravelerTests : XCTestCase

@end

@implementation Time_TravelerTests

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

-(void) testSetSleepTime
{
	TripDetails *trip = [[TripDetails alloc] init];
	[trip setSleepTime: 10];
	XCTAssertNotNil(trip.sleepTime, @"Sleep time unset");
}

-(void) testSetWakeTime
{
	TripDetails *trip = [[TripDetails alloc] init];
	[trip setWakeTime: 23];
	XCTAssertNotNil(trip.wakeTime, @"Wake time unset");
}

-(void) testSetDepDay
{
	TripDetails *trip = [[TripDetails alloc] init];
	[trip setDepartureDay: 31];
	XCTAssertNotNil(trip.departureDay, @"Departure Day unset");
}

-(void) testValidDepDay
{
	TripDetails *trip = [[TripDetails alloc] init];
	[trip setDepartureDay: 31];
	XCTAssertTrue(trip.departureDay <= 31, @"Departure Day Not within bounds");
}

-(void) testSetDepMonth
{
	TripDetails *trip = [[TripDetails alloc] init];
	[trip setDepartureMonth: 11];
	XCTAssertNotNil(trip.departureMonth, @"Departure Month unset");
}

-(void) testValidDepMonth
{
	TripDetails *trip = [[TripDetails alloc] init];
	[trip setDepartureMonth: 11];
	XCTAssertTrue(trip.departureMonth <= 12, @"Departure Month Not within bounds");
}

-(void) testInvalidDepMonth
{
	TripDetails *trip = [[TripDetails alloc] init];
	[trip setDepartureMonth: 13];
	XCTAssertFalse(trip.departureMonth <=12, @"Departure Month not within bounds");	
}

-(void) testSetDepYear
{
	TripDetails *trip = [[TripDetails alloc] init];
	[trip setDepartureYear: 11];
	XCTAssertNotNil(trip.departureYear, @"Departure Year unset");
}

-(void) testValidDepYear
{
	TripDetails *trip = [[TripDetails alloc] init];
	[trip setDepartureYear: 11];
	XCTAssertTrue(trip.departureYear >= 2014, @"Departure Year in past");
}

-(void) testSetDestinationLocation
{
	TripDetails *trip = [[TripDetails alloc] init];
	[trip setDestinationLocation: 10];
	XCTAssertNotNil(trip.destinationLocation, @"Destination Location unset");
}

-(void) testSourceLocation
{
	TripDetails *trip = [[TripDetails alloc] init];
	[trip setSourceLocation: 23];
	XCTAssertNotNil(trip.sourceLocation, @"Source Location unset");
}

-(void) testDiffTimeZones
{
	TripDetails * trip = [[TripDetails alloc] init];
	//Subtract destination timezone from current timezone (from phone API), and check that this value is non-zero
}

@end