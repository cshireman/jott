//
//  TextFormattingViewModel.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//

import SwiftUI
import UIKit

@MainActor
class TextFormattingViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var selectionRange: NSRange?
    
    // Reference to a UITextView for selection handling
    private var textView: UITextView?
    
    // Plain text getter/setter (for linking with NoteEditorViewModel)
    var plainText: String {
        get { return text }
        set { text = newValue }
    }
    
    func setTextView(_ textView: UITextView) {
        self.textView = textView
    }
    
    // Apply formatting at current selection or cursor position
    func applyFormatting(_ style: FormattingStyle) {
        guard let textView = textView else { return }
        
        // Get selection range
        let selectedRange = textView.selectedRange
        
        // If there's a selection, wrap it with formatting markers
        if selectedRange.length > 0 {
            let selectedText = (text as NSString).substring(with: selectedRange)
            
            // Apply appropriate formatting based on style
            var formattedText = ""
            switch style {
            case .bold, .italic, .highlight:
                formattedText = "\(style.rawValue)\(selectedText)\(style.rawValue)"
            case .heading:
                // Apply heading at the start of the line
                let lineRange = (text as NSString).lineRange(for: selectedRange)
                let lineStart = lineRange.location
                let currentLine = (text as NSString).substring(with: lineRange)
                
                if currentLine.hasPrefix(style.rawValue) {
                    // Remove heading if already there
                    let newLine = currentLine.replacingOccurrences(of: style.rawValue, with: "")
                    let newText = NSMutableString(string: text)
                    newText.replaceCharacters(in: lineRange, with: newLine)
                    text = newText as String
                    textView.text = text
                    textView.selectedRange = NSRange(location: selectedRange.location, length: selectedRange.length - style.rawValue.count)
                    return
                } else {
                    // Add heading at the start of the line
                    let indentedText = NSMutableString(string: text)
                    indentedText.insert(style.rawValue, at: lineStart)
                    text = indentedText as String
                    textView.text = text
                    textView.selectedRange = NSRange(location: selectedRange.location + style.rawValue.count, length: selectedRange.length)
                    return
                }
            case .bulletList, .numberedList, .checkList, .checkedItem:
                // Apply list formatting at the start of each selected line
                let lines = selectedText.components(separatedBy: .newlines)
                formattedText = lines.map { "\(style.rawValue)\($0)" }.joined(separator: "\n")
            case .link:
                // For link, replace with a simplified format that's easy to edit
                formattedText = "[\(selectedText)](url)"
            }
            
            // Replace the selected text with the formatted text
            let newText = NSMutableString(string: text)
            newText.replaceCharacters(in: selectedRange, with: formattedText)
            text = newText as String
            
            // Update the text view
            textView.text = text
            
            // Adjust selection to place cursor after the inserted text
            textView.selectedRange = NSRange(
                location: selectedRange.location + formattedText.count,
                length: 0
            )
        } else {
            // No selection - insert formatting markers at cursor position
            let cursorPosition = selectedRange.location
            
            switch style {
            case .bold, .italic, .highlight:
                // Insert empty formatting markers and position cursor between them
                let markers = "\(style.rawValue)\(style.rawValue)"
                let newText = NSMutableString(string: text)
                newText.insert(markers, at: cursorPosition)
                text = newText as String
                textView.text = text
                textView.selectedRange = NSRange(location: cursorPosition + style.rawValue.count, length: 0)
            case .heading:
                // Insert heading at the start of the current line
                let lineRange = (text as NSString).lineRange(for: NSRange(location: cursorPosition, length: 0))
                let lineStart = lineRange.location
                let currentLine = (text as NSString).substring(with: lineRange)
                
                if currentLine.hasPrefix(style.rawValue) {
                    // Remove heading if already there
                    let newLine = currentLine.replacingOccurrences(of: style.rawValue, with: "")
                    let newText = NSMutableString(string: text)
                    newText.replaceCharacters(in: lineRange, with: newLine)
                    text = newText as String
                    textView.text = text
                } else {
                    // Add heading at the start of the line
                    let newText = NSMutableString(string: text)
                    newText.insert(style.rawValue, at: lineStart)
                    text = newText as String
                    textView.text = text
                    textView.selectedRange = NSRange(location: cursorPosition + style.rawValue.count, length: 0)
                }
            case .bulletList, .numberedList, .checkList, .checkedItem:
                // Insert list marker at current position
                let newText = NSMutableString(string: text)
                newText.insert(style.rawValue, at: cursorPosition)
                text = newText as String
                textView.text = text
                textView.selectedRange = NSRange(location: cursorPosition + style.rawValue.count, length: 0)
            case .link:
                // Insert link template
                let linkTemplate = "[Link Text](url)"
                let newText = NSMutableString(string: text)
                newText.insert(linkTemplate, at: cursorPosition)
                text = newText as String
                textView.text = text
                textView.selectedRange = NSRange(location: cursorPosition + 1, length: 9) // Select "Link Text"
            }
        }
    }
    
    // Toggle checklist item state
    func toggleChecklistItem() {
        guard let textView = textView else { return }
        
        // Get current line
        let cursorPosition = textView.selectedRange.location
        let lineRange = (text as NSString).lineRange(for: NSRange(location: cursorPosition, length: 0))
        let currentLine = (text as NSString).substring(with: lineRange)
        
        // Check if line is a checklist item
        if currentLine.hasPrefix(FormattingStyle.checkList.rawValue) {
            // Change to checked
            let newLine = currentLine.replacingOccurrences(
                of: FormattingStyle.checkList.rawValue,
                with: FormattingStyle.checkedItem.rawValue
            )
            let newText = NSMutableString(string: text)
            newText.replaceCharacters(in: lineRange, with: newLine)
            text = newText as String
            textView.text = text
        } else if currentLine.hasPrefix(FormattingStyle.checkedItem.rawValue) {
            // Change to unchecked
            let newLine = currentLine.replacingOccurrences(
                of: FormattingStyle.checkedItem.rawValue,
                with: FormattingStyle.checkList.rawValue
            )
            let newText = NSMutableString(string: text)
            newText.replaceCharacters(in: lineRange, with: newLine)
            text = newText as String
            textView.text = text
        }
    }
}
