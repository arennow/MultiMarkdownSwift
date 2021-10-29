# MultiMarkdownSwift

This is just a thin-but-pleasant Swifty wrapper over [my feature-free, SPM-enabling fork](https://github.com/arennow/MultiMarkdown-6) of Fletcher Penny's excellent [MultiMarkdown-6](https://github.com/fletcher/MultiMarkdown-6).

## Usage
It's just one function and two enums.

```swift
static func convert(_ source: String, to format: Format = .html, extensions: Extensions = []) throws -> String
```
