//
//  MethodSwizzlingTests.m
//  MethodSwizzlingTests
//
//  Created by lijian on 14-4-30.
//  Copyright (c) 2014年 lijian. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface MethodSwizzlingTests : XCTestCase

@end

@implementation MethodSwizzlingTests

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

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
