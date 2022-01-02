# MultiMarkdownSwift

This is just a thin-but-pleasant Swifty wrapper over [my feature-free, SPM-enabling fork](https://github.com/arennow/MultiMarkdown-6) of Fletcher Penny's excellent [MultiMarkdown-6](https://github.com/fletcher/MultiMarkdown-6).

## Usage
The simplest use is to call a single static method.

```swift
static func convert(_ source: String, to format: Format = .html, extensions: Extensions = []) throws -> String
```

MultiMarkdownSwift also supports extracting metadata from a source:

```swift
let doc = try MultiMarkdown(source: src)
let meta = doc.getMetadata()
let value: String? = meta["author"]
```
