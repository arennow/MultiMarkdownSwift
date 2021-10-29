import MultiMarkdown

public struct MultiMarkdownSwift {
	public static let version = String(cString: mmd_version())	
}
