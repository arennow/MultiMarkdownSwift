import MultiMarkdown
import Foundation

public final class MultiMarkdown {
	public static let version = "0.3.0"
	public static let underlyingVersion = String(cString: mmd_version())
	
	private let engine: OpaquePointer
	
	public init(source: String, extensions: Extensions = []) throws {
		let options = UInt(extensions.rawValue)
		guard let engine = mmd_engine_create_with_string(source, options) else { throw ConversionError() }
		mmd_engine_set_language(engine, Int16(ENGLISH.rawValue))
		self.engine = engine
	}
	
	deinit {
		mmd_engine_free(engine, true)
	}
	
	public func convert(to format: Format = .html) throws -> String {
		guard let outputCString = mmd_engine_convert(self.engine, format.rawValue) else { throw ConversionError() }
		
		let length = strlen(outputCString)
		guard let outString = stringFromOwnedStringPointer(outputCString, length: length) else {
			throw StringCreationError(ptr: outputCString, length: length)
		}
		
		return outString
	}
	
	/// Extracts the metadata from the header of the document.
	///
	/// - Warning: Keys are normalized to lowercase.
	/// - Returns: A `String` `subscript`able type (`Metadata`) that correctly normailizes the keys in the key: value pairs.
	public func getMetadata() -> Metadata {
		guard let keyStringPtr = mmd_engine_metadata_keys(self.engine),
			  let keyString = stringFromOwnedStringPointer(keyStringPtr)
		else { return .init(dictionary: [:]) }
		
		let keys = keyString.split(separator: "\n").map(String.init)
		
		var outDict = Dictionary<String, String>()
		outDict.reserveCapacity(keys.count)
		
		for key in keys {
			outDict[key] = String(cString: mmd_engine_metavalue_for_key(self.engine, key))
		}
		
		return Metadata(dictionary: outDict)
	}
}

public extension MultiMarkdown {
	static func convert(_ source: String, to format: Format = .html, extensions: Extensions = []) throws -> String {
		try Self.init(source: source, extensions: extensions).convert(to: format)
	}
}

public extension MultiMarkdown {
	enum Format {
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
	
	struct Extensions: OptionSet {
		public let rawValue: parser_extensions.RawValue
		
		public init(rawValue: parser_extensions.RawValue) {
			self.rawValue = rawValue
		}
		
		/// Markdown compatibility mode
		public static let compatibility = Extensions(rawValue: EXT_COMPATIBILITY.rawValue)
		/// Create complete document
		public static let complete = Extensions(rawValue: EXT_COMPLETE.rawValue)
		/// Create snippet only
		public static let snippet = Extensions(rawValue: EXT_SNIPPET.rawValue)
		/// Enable Smart quotes
		public static let smart = Extensions(rawValue: EXT_SMART.rawValue)
		/// Enable Footnotes
		public static let notes = Extensions(rawValue: EXT_NOTES.rawValue)
		/// Don't add anchors to headers, etc.
		public static let noLabels = Extensions(rawValue: EXT_NO_LABELS.rawValue)
		/// Process Markdown inside HTML
		public static let processHTML = Extensions(rawValue: EXT_PROCESS_HTML.rawValue)
		/// Don't parse Metadata
		public static let noMetadata = Extensions(rawValue: EXT_NO_METADATA.rawValue)
		/// Mask email addresses
		public static let obfuscate = Extensions(rawValue: EXT_OBFUSCATE.rawValue)
		/// Critic Markup Support
		public static let critic = Extensions(rawValue: EXT_CRITIC.rawValue)
		/// Accept all proposed changes
		public static let criticAccept = Extensions(rawValue: EXT_CRITIC_ACCEPT.rawValue)
		/// Reject all proposed changes
		public static let criticReject = Extensions(rawValue: EXT_CRITIC_REJECT.rawValue)
		/// Use random numbers for footnote links
		public static let randomFoot = Extensions(rawValue: EXT_RANDOM_FOOT.rawValue)
		/// Perform transclusion(s)
		public static let transclude = Extensions(rawValue: EXT_TRANSCLUDE.rawValue)
		/// Convert from OPML before processing source text
		public static let parseOPML = Extensions(rawValue: EXT_PARSE_OPML.rawValue)
		/// Convert from ITMZ (iThoughts) before processing source text
		public static let parseITMZ = Extensions(rawValue: EXT_PARSE_ITMZ.rawValue)
		/// Use random numbers for header labels (unless manually defined)
		public static let randomLabels = Extensions(rawValue: EXT_RANDOM_LABELS.rawValue)
	}
}

public extension MultiMarkdown {
	struct ConversionError: Error {}
	
	struct StringCreationError: Error {
		let nonUTF8Data: Data
		
		fileprivate init(ptr: UnsafeMutablePointer<CChar>, length: Int) {
			self.nonUTF8Data = Data(bytesNoCopy: ptr, count: length, deallocator: .free)
		}
	}
}

public extension MultiMarkdown {
	struct Metadata: Equatable {
		public let dictionary: Dictionary<String, String>
		
		public subscript(key: String) -> String? {
			let keyCharSeq = key.lazy.compactMap { c -> String? in
				if c.isWhitespace {
					return nil
				} else if c.isUppercase {
					return c.lowercased()
				} else {
					return String(c)
				}
			}
			
			return self.dictionary[keyCharSeq.joined()]
		}
	}
}

fileprivate func stringFromOwnedStringPointer(_ ptr: UnsafeMutablePointer<CChar>?, length: Int? = nil) -> String? {
	guard let ptr = ptr else { return nil }
	let length = length ?? strlen(ptr)
	return String(bytesNoCopy: ptr, length: length, encoding: .utf8, freeWhenDone: true)
}
