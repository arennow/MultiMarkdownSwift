import MultiMarkdown
import Foundation

public struct MultiMarkdownSwift {
	public static let version = String(cString: mmd_version())
	
	public static func convert(_ source: String, to format: Format = .html) throws -> String {
		let options = UInt(EXT_NOTES.rawValue | EXT_SMART.rawValue)
		
		guard let outputCString = mmd_string_convert(source, options, format.rawValue, Int16(ENGLISH.rawValue)) else {
			struct ConversionError: Error {}
			throw ConversionError()
		}
		
		defer {
			free(outputCString)
		}
		
		return String(cString: outputCString)
	}
}

extension MultiMarkdownSwift {
	public enum Format {
		typealias RawValue = Int16
		
		case html
		case epub
		case latex
		case beamer
		case memoir
		case fodt
		case odf
		case textbundle
		case textbundleCompressed
		case opml
		case itmz
		case mmd
		case htmlWithAssets
		
		var rawValue: RawValue {
			switch self {
				case .html: return numericCast(FORMAT_HTML.rawValue)
				case .epub: return numericCast(FORMAT_EPUB.rawValue)
				case .latex: return numericCast(FORMAT_LATEX.rawValue)
				case .beamer: return numericCast(FORMAT_BEAMER.rawValue)
				case .memoir: return numericCast(FORMAT_MEMOIR.rawValue)
				case .fodt: return numericCast(FORMAT_FODT.rawValue)
				case .odf: return numericCast(FORMAT_ODT.rawValue)
				case .textbundle: return numericCast(FORMAT_TEXTBUNDLE.rawValue)
				case .textbundleCompressed: return numericCast(FORMAT_TEXTBUNDLE_COMPRESSED.rawValue)
				case .opml: return numericCast(FORMAT_OPML.rawValue)
				case .itmz: return numericCast(FORMAT_ITMZ.rawValue)
				case .mmd: return numericCast(FORMAT_MMD.rawValue)
				case .htmlWithAssets: return numericCast(FORMAT_HTML_WITH_ASSETS.rawValue)
			}
		}
	}
}
