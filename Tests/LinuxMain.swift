#if os(Linux)

import XCTest
import AppTests

var tests = [XCTestCaseEntry]()
tests += AppTests.__allTests()

XCTMain(tests)

#endif
