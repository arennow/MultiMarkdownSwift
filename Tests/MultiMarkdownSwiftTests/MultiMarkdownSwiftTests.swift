import XCTest
@testable import MultiMarkdownSwift

final class MultiMarkdownSwiftTests: XCTestCase {
	func testVersion() {
		XCTAssertEqual(MultiMarkdownSwift.version, "6.6.1")
	}
	
	func testHTMLConversion() throws {
		let src = """
		# Header
		text
		"""
		let dest = try MultiMarkdownSwift.convert(src, to: .html)
		
		XCTAssert(dest.contains("</h1>"))
	}
	
	func testLaTeXConversion() throws {
		let src = """
		# Header
		text
		"""
		let dest = try MultiMarkdownSwift.convert(src, to: .latex)
		
		XCTAssert(dest.contains("\\part"))
	}
}
