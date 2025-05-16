//
//  FormattedTextParser.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//

import Foundation
import SwiftUI

class FormattedTextParser {
    @MainActor
    private static let blockPatterns: [(pattern: NSRegularExpression, handler: (String) -> String)] = {
        return [
            // Bullet lists
            (try! NSRegularExpression(pattern: "^([ \\t]*)- (.+)$", options: .anchorsMatchLines),
             { match in
                if let range = match.range(of: "^([ \\t]*)- ", options: .regularExpression) {
                    let prefix = match[range]
                    return prefix.replacingOccurrences(of: "- ", with: "• ") + match[range.upperBound...]
                }
                return match
            }),
            
            // Numbered lists: "1. Item" -> "1. Item" (keep as is, but identify for styling)
            (try! NSRegularExpression(pattern: "^([ \\t]*)\\d+\\. (.+)$", options: .anchorsMatchLines),
             { $0 }),
            
            // Checkboxes: "- [ ] Item" -> "☐ Item"
            (try! NSRegularExpression(pattern: "^([ \\t]*)- \\[ \\] (.+)$", options: .anchorsMatchLines),
             { match in
                if let range = match.range(of: "^([ \\t]*)- \\[ \\] ", options: .regularExpression) {
                    let prefix = match[..<range.lowerBound]
                    return prefix + "☐ " + match[range.upperBound...]
                }
                return match
            }),
            
            // Checked items: "- [x] Item" -> "☑ Item"
            (try! NSRegularExpression(pattern: "^([ \\t]*)- \\[x\\] (.+)$", options: .anchorsMatchLines),
             { match in
                if let range = match.range(of: "^([ \\t]*)- \\[x\\] ", options: .regularExpression) {
                    let prefix = match[..<range.lowerBound]
                    return prefix + "☑ " + match[range.upperBound...]
                }
                return match
            }),
            
            // Headings: "# Heading" -> "Heading" (but with heading style)
            (try! NSRegularExpression(pattern: "^(#+) (.+)$", options: .anchorsMatchLines),
             { $0 })
        ]
    }()
    
    private static let inlineMarkers = [
        ("**", "**"), // bold
        ("_", "_"),   // italic
        ("==", "==")  // highlight
    ]
    
    @MainActor
    static func parse(text: String) -> [FormattedTextSegment] {
        // Pre-process text for block-level formats
        var processedText = text
        let lines = processedText.components(separatedBy: .newlines)
        var transformedLines: [String] = []
        
        for line in lines {
            var transformedLine = line
            for (pattern, handler) in blockPatterns {
                if let match = pattern.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
                    let nsString = line as NSString
                    transformedLine = handler(nsString as String)
                    break
                }
            }
            transformedLines.append(transformedLine)
        }
        
        processedText = transformedLines.joined(separator: "\n")
        
        // Create segments with optimized inline format processing
        var segments: [FormattedTextSegment] = []
        var currentIndex = processedText.startIndex
        
        while currentIndex < processedText.endIndex {
            var foundFormat = false
            
            // Check for format markers
            for (startMarker, endMarker) in inlineMarkers {
                if processedText[currentIndex...].starts(with: startMarker),
                   let endRange = processedText.range(of: endMarker, range: processedText.index(after: currentIndex)..<processedText.endIndex) {
                    
                    let formatText = processedText[processedText.index(currentIndex, offsetBy: startMarker.count)..<endRange.lowerBound]
                    
                    // Add formatted segment
                    let segment: FormattedTextSegment
                    switch startMarker {
                    case "**":
                        segment = FormattedTextSegment(
                            text: String(formatText),
                            font: .boldSystemFont(ofSize: UIFont.systemFontSize)
                        )
                    case "_":
                        segment = FormattedTextSegment(
                            text: String(formatText),
                            font: .italicSystemFont(ofSize: UIFont.systemFontSize)
                        )
                    case "==":
                        segment = FormattedTextSegment(
                            text: String(formatText),
                            backgroundColor: Color.yellow.opacity(0.3)
                        )
                    default:
                        segment = FormattedTextSegment(text: String(formatText))
                    }
                    
                    segments.append(segment)
                    currentIndex = endRange.upperBound
                    foundFormat = true
                    break
                }
            }
            
            // Handle bullet list item
            if processedText[currentIndex] == "•" {
                // Handle bullet list item
                let lineEnd = processedText[currentIndex...].firstIndex(of: "\n") ?? processedText.endIndex
                let listItem = processedText[currentIndex..<lineEnd]
                
                segments.append(FormattedTextSegment(
                    text: String(listItem),
                    font: nil,
                    foregroundColor: nil,
                    listType: .bullet
                ))
                
                currentIndex = lineEnd == processedText.endIndex ? lineEnd : processedText.index(after: lineEnd)
                foundFormat = true
            }
            // Handle checkbox item
            else if processedText[currentIndex] == "☐" || processedText[currentIndex] == "☑" {
                // Handle checkbox item
                let lineEnd = processedText[currentIndex...].firstIndex(of: "\n") ?? processedText.endIndex
                let checkboxItem = processedText[currentIndex..<lineEnd]
                
                segments.append(FormattedTextSegment(
                    text: String(checkboxItem),
                    font: nil,
                    foregroundColor: nil,
                    listType: processedText[currentIndex] == "☐" ? .unchecked : .checked
                ))
                
                currentIndex = lineEnd == processedText.endIndex ? lineEnd : processedText.index(after: lineEnd)
                foundFormat = true
            }
            // Handle headings
            else if let headingMatch = processedText.range(of: "^#+\\s+", options: .regularExpression, range: currentIndex..<processedText.endIndex),
                    headingMatch.lowerBound == currentIndex {
                
                let lineEnd = processedText[currentIndex...].firstIndex(of: "\n") ?? processedText.endIndex
                let headingText = processedText[headingMatch.upperBound..<lineEnd]
                let level = processedText[headingMatch.lowerBound..<headingMatch.upperBound].filter { $0 == "#" }.count
                
                var fontSize: CGFloat = UIFont.systemFontSize
                switch level {
                case 1: fontSize = 24
                case 2: fontSize = 22
                case 3: fontSize = 20
                case 4: fontSize = 18
                default: fontSize = 16
                }
                
                segments.append(FormattedTextSegment(
                    text: String(headingText),
                    font: .boldSystemFont(ofSize: fontSize),
                    foregroundColor: nil,
                    headingLevel: level
                ))
                
                currentIndex = lineEnd == processedText.endIndex ? lineEnd : processedText.index(after: lineEnd)
                foundFormat = true
            }
            
            // Handle plain text
            if !foundFormat {
                let nextFormatIndex = inlineMarkers.compactMap { marker -> String.Index? in
                    processedText.range(of: marker.0, range: currentIndex..<processedText.endIndex)?.lowerBound
                }.min()
                
                let endIndex = nextFormatIndex ?? processedText.endIndex
                if currentIndex < endIndex {
                    segments.append(FormattedTextSegment(
                        text: String(processedText[currentIndex..<endIndex])
                    ))
                    currentIndex = endIndex
                } else {
                    currentIndex = processedText.index(after: currentIndex)
                }
            }
        }
        
        return segments
    }
}

// Define a formatted text segment with display properties
struct FormattedTextSegment: Identifiable {
    enum ListType {
        case none, bullet, numbered, checked, unchecked
    }
    
    let id = UUID()
    let text: String
    let font: UIFont?
    let foregroundColor: Color?
    let backgroundColor: Color?
    let listType: ListType
    let headingLevel: Int
    
    init(text: String, font: UIFont? = nil, foregroundColor: Color? = nil, 
         backgroundColor: Color? = nil, listType: ListType = .none, headingLevel: Int = 0) {
        self.text = text
        self.font = font
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.listType = listType
        self.headingLevel = headingLevel
    }
}
