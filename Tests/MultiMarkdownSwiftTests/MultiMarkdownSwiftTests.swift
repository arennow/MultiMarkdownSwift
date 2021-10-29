import XCTest
@testable import MultiMarkdownSwift

final class MultiMarkdownSwiftTests: XCTestCase {
	func testVersion() {
		XCTAssertEqual(MultiMarkdownSwift.version, "6.6.1")
	}
}
