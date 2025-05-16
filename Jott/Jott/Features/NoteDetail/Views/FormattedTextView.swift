//
//  FormattedTextView.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//


// FormattedTextView.swift
import SwiftUI

struct FormattedTextView: View {
    let text: String
    let segments: [FormattedTextSegment]
    
    init(text: String) {
        self.text = text
        self.segments = FormattedTextParser.parse(text: text)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(segments) { segment in
                switch segment.listType {
                case .bullet, .numbered, .checked, .unchecked:
                    HStack(alignment: .top, spacing: 4) {
                        Text(segment.text)
                            .font(segment.font.map { Font(UIFont(descriptor: $0.fontDescriptor, size: $0.pointSize)) } ?? .body)
                            .foregroundColor(segment.foregroundColor ?? .primary)
                            .padding(.leading, 20)  // Indent list items
                    }
                    
                default:
                    Text(segment.text)
                        .font(segment.font.map { Font(UIFont(descriptor: $0.fontDescriptor, size: $0.pointSize)) } ?? .body)
                        .foregroundColor(segment.foregroundColor ?? .primary)
                        .background(segment.backgroundColor)
                        .padding(.top, segment.headingLevel > 0 ? 8 : 0)
                        .padding(.bottom, segment.headingLevel > 0 ? 4 : 0)
                }
            }
        }
    }
}