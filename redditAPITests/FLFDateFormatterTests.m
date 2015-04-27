//
//  FLFDateFormatterTests.m
//  redditAPI
//
//  Created by Woudini on 4/26/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFDateFormatter.h"
#import <XCTest/XCTest.h>

@interface FLFDateFormatterTests : XCTestCase
@property (nonatomic) FLFDateFormatter *dateFormatter;
@end

@implementation FLFDateFormatterTests

- (void)setUp {
    [super setUp];
    self.dateFormatter = [[FLFDateFormatter alloc] init];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1430116395.0];
    NSLog(@"sample date is %@",date);
    NSLog(@"formatted date is %@",[self.dateFormatter formatDate:date]);
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSeconds {
    double thirtySeconds = -30;
    NSDate *thirtySecondsAgo = [NSDate dateWithTimeIntervalSinceNow:thirtySeconds];
    NSString *dateString = [self.dateFormatter formatDate:thirtySecondsAgo];
    XCTAssertEqualObjects(dateString, @"30s", @"String should be '30s'");
    // XCTAssertEqual(dateString, @"30s", @"String should be '30s'");
}

- (void)testMinutes {
    double thirtyMinutes = -60*30;
    NSDate *thirtyMinutesAgo = [NSDate dateWithTimeIntervalSinceNow:thirtyMinutes];
    NSString *dateString = [self.dateFormatter formatDate:thirtyMinutesAgo];
    XCTAssertEqualObjects(dateString, @"30m", @"String should be '30m'");
    // XCTAssertEqual(dateString, @"30s", @"String should be '30s'");
}

- (void)testHours {
    double twelveHours = -60*60*12;
    NSDate *twelveHoursAgo = [NSDate dateWithTimeIntervalSinceNow:twelveHours];
    NSString *dateString = [self.dateFormatter formatDate:twelveHoursAgo];
    XCTAssertEqualObjects(dateString, @"12h", @"String should be '12h'");
    // XCTAssertEqual(dateString, @"30s", @"String should be '30s'");
}

- (void)testDays {
    double fiveDays = -60*60*24*1.5;
    NSDate *fiveDaysAgo = [NSDate dateWithTimeIntervalSinceNow:fiveDays];
    NSString *dateString = [self.dateFormatter formatDate:fiveDaysAgo];
    XCTAssertEqualObjects(dateString, @"1d", @"String should be '1d'");
    // XCTAssertEqual(dateString, @"30s", @"String should be '30s'");
}

- (void)testWeeks {
    double fortyWeeks = -60*60*24*7*40;
    NSDate *fortyWeeksAgo = [NSDate dateWithTimeIntervalSinceNow:fortyWeeks];
    NSString *dateString = [self.dateFormatter formatDate:fortyWeeksAgo];
    XCTAssertEqualObjects(dateString, @"40w", @"String should be '40w'");
    // XCTAssertEqual(dateString, @"30s", @"String should be '30s'");
}

- (void)testYears {
    double twoYears = -60*60*24*7*52*2;
    NSDate *twoYearsAgo = [NSDate dateWithTimeIntervalSinceNow:twoYears];
    NSString *dateString = [self.dateFormatter formatDate:twoYearsAgo];
    XCTAssertEqualObjects(dateString, @"2y", @"String should be '2y'");
    // XCTAssertEqual(dateString, @"30s", @"String should be '30s'");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
