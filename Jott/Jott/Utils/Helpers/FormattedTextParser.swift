//
//  FormattedTextParser.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//

import Foundation
import SwiftUI

class FormattedTextParser {
    // Convert text with markers to array of formatted text segments
    static func parse(text: String) -> [FormattedTextSegment] {
        // Preprocess text to handle special cases
        var processedText = text
        
        // Handle processing for list items and other block-level formats
        let blockPatterns: [(pattern: String, handler: (String) -> String)] = [
            // Bullet lists: "- Item" -> "• Item"
            ("^([ \\t]*)- (.+)$", { match -> String in
                if let range = match.range(of: "^([ \\t]*)- ", options: .regularExpression) {
                    let prefix = match[range]
                    return prefix.replacingOccurrences(of: "- ", with: "• ") + match[range.upperBound...]
                }
                return match
            }),
            
            // Numbered lists: "1. Item" -> "1. Item" (keep as is, but identify for styling)
            ("^([ \\t]*)\\d+\\. (.+)$", { $0 }),
            
            // Checkboxes: "- [ ] Item" -> "☐ Item"
            ("^([ \\t]*)- \\[ \\] (.+)$", { match -> String in
                if let range = match.range(of: "^([ \\t]*)- \\[ \\] ", options: .regularExpression) {
                    let prefix = match[..<range.lowerBound]
                    return prefix + "☐ " + match[range.upperBound...]
                }
                return match
            }),
            
            // Checked items: "- [x] Item" -> "☑ Item"
            ("^([ \\t]*)- \\[x\\] (.+)$", { match -> String in
                if let range = match.range(of: "^([ \\t]*)- \\[x\\] ", options: .regularExpression) {
                    let prefix = match[..<range.lowerBound]
                    return prefix + "☑ " + match[range.upperBound...]
                }
                return match
            }),
            
            // Headings: "# Heading" -> "Heading" (but with heading style)
            ("^(#+) (.+)$", { $0 })
        ]
        
        // Apply block-level transformations
        let lines = processedText.components(separatedBy: .newlines)
        var transformedLines: [String] = []
        
        for line in lines {
            var transformedLine = line
            
            for (pattern, handler) in blockPatterns {
                if let _ = line.range(of: pattern, options: .regularExpression) {
                    transformedLine = handler(line)
                    break
                }
            }
            
            transformedLines.append(transformedLine)
        }
        
        processedText = transformedLines.joined(separator: "\n")
        
        // Create segments based on inline formatting patterns
        var segments: [FormattedTextSegment] = []
        var currentIndex = processedText.startIndex
        
        while currentIndex < processedText.endIndex {
            // Check for the start of each format marker
            if let boldRange = processedText.range(of: "**", range: currentIndex..<processedText.endIndex),
               boldRange.lowerBound == currentIndex,
               let endBold = processedText.range(of: "**", range: boldRange.upperBound..<processedText.endIndex) {
                
                // Extract the bold text
                let boldText = processedText[boldRange.upperBound..<endBold.lowerBound]
                
                // Add a bold segment
                segments.append(FormattedTextSegment(
                    text: String(boldText),
                    font: .boldSystemFont(ofSize: UIFont.systemFontSize),
                    foregroundColor: nil
                ))
                
                // Move past the end marker
                currentIndex = endBold.upperBound
            }
            else if let italicRange = processedText.range(of: "_", range: currentIndex..<processedText.endIndex),
                    italicRange.lowerBound == currentIndex,
                    let endItalic = processedText.range(of: "_", range: italicRange.upperBound..<processedText.endIndex) {
                
                // Extract the italic text
                let italicText = processedText[italicRange.upperBound..<endItalic.lowerBound]
                
                // Add an italic segment
                segments.append(FormattedTextSegment(
                    text: String(italicText),
                    font: .italicSystemFont(ofSize: UIFont.systemFontSize),
                    foregroundColor: nil
                ))
                
                // Move past the end marker
                currentIndex = endItalic.upperBound
            }
            else if let highlightRange = processedText.range(of: "==", range: currentIndex..<processedText.endIndex),
                    highlightRange.lowerBound == currentIndex,
                    let endHighlight = processedText.range(of: "==", range: highlightRange.upperBound..<processedText.endIndex) {
                
                // Extract the highlighted text
                let highlightText = processedText[highlightRange.upperBound..<endHighlight.lowerBound]
                
                // Add a highlighted segment
                segments.append(FormattedTextSegment(
                    text: String(highlightText),
                    font: nil,
                    foregroundColor: nil,
                    backgroundColor: Color.yellow.opacity(0.3)
                ))
                
                // Move past the end marker
                currentIndex = endHighlight.upperBound
            }
            else if processedText[currentIndex] == "•" {
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
            }
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
            }
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
            }
            else {
                // Handle plain text until the next format marker
                let nextFormatMarker = [
                    processedText.range(of: "**", range: currentIndex..<processedText.endIndex),
                    processedText.range(of: "_", range: currentIndex..<processedText.endIndex),
                    processedText.range(of: "==", range: currentIndex..<processedText.endIndex),
                    processedText.range(of: "\n•", range: currentIndex..<processedText.endIndex),
                    processedText.range(of: "\n☐", range: currentIndex..<processedText.endIndex),
                    processedText.range(of: "\n☑", range: currentIndex..<processedText.endIndex),
                    processedText.range(of: "\n#", range: currentIndex..<processedText.endIndex)
                ].compactMap { $0 }.min { $0.lowerBound < $1.lowerBound }
                
                let endIndex = nextFormatMarker?.lowerBound ?? processedText.endIndex
                
                if currentIndex < endIndex {
                    let plainText = processedText[currentIndex..<endIndex]
                    segments.append(FormattedTextSegment(
                        text: String(plainText),
                        font: nil,
                        foregroundColor: nil
                    ))
                    
                    currentIndex = endIndex
                } else if currentIndex == endIndex && currentIndex != processedText.endIndex {
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
