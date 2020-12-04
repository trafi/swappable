import XCTest

import swappableTests

var tests = [XCTestCaseEntry]()
tests += swappableTests.allTests()
XCTMain(tests)
