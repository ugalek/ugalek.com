import XCTest

extension CategoryRepositoryTest {
    static let __allTests = [
        ("testCategories", testCategories),
    ]
}

extension UserRepositoryTest {
    static let __allTests = [
        ("testUsers", testUsers),
    ]
}

extension PostRepositoryTest {
    static let __allTests = [
        ("testPosts", testPosts),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CategoryRepositoryTest.__allTests),
        testCase(UserRepositoryTest.__allTests),
        testCase(PostRepositoryTest.__allTests),
    ]
}
#endif
