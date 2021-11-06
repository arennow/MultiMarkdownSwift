import XCTest
@testable import MultiMarkdownSwift

final class MultiMarkdownSwiftTests: XCTestCase {
	func testVersion() {
		XCTAssertEqual(MultiMarkdown.underlyingVersion, "6.6.1")
	}
	
	func testHTMLConversion() throws {
		let src = """
		# Header
		text
		"""
		let dest = try MultiMarkdown.convert(src, to: .html)
		
		XCTAssert(dest.contains("</h1>"))
	}
	
	func testLaTeXConversion() throws {
		let src = """
		# Header
		text
		"""
		let dest = try MultiMarkdown.convert(src, to: .latex)
		
		XCTAssert(dest.contains("\\part"))
	}
	
	func testCompleteDoc() throws {
		let src = "abc"
		
		do {
			let dest = try MultiMarkdown.convert(src, extensions: .complete)
			XCTAssert(dest.contains("<html"))
		}
		
		do {
			let dest = try MultiMarkdown.convert(src)
			XCTAssertFalse(dest.contains("<html"))
		}
	}
	
	func testMetadataExtraction() throws {
		let src = """
		---
		Author: Aaron Rennow
		Date: Tuesday
		ABC: xyz
		---
		# Book
		Prose
		"""
		
		let doc = try MultiMarkdown(source: src)
		let meta = doc.getMetadata()
		XCTAssertEqual(meta.dictionary, ["author": "Aaron Rennow", "date": "Tuesday", "abc": "xyz"])
		XCTAssertEqual(meta["auThor"], "Aaron Rennow")
	}
	
	func testEmptyMetadataExtraction() throws {
		let src = """
		# Book
		Prose
		"""
		
		let doc = try MultiMarkdown(source: src)
		let meta = doc.getMetadata()
		XCTAssertEqual(meta.dictionary, [:])
	}
}
