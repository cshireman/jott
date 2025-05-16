//
//  FormattingStyle.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//

import Foundation
enum FormattingStyle: String {
    case bold = "**"
    case italic = "_"
    case heading = "# "
    case bulletList = "- "
    case numberedList = "1. "
    case checkList = "- [ ] "
    case checkedItem = "- [x] "
    case highlight = "=="
    case link = "[]() "  // For handling links
}
