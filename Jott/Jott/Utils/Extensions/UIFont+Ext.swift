//
//  UIFont+Ext.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//

import UIKit

extension UIFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
    
    func withBold() -> UIFont? {
        return withTraits(traits: .traitBold)
    }
    
    func withItalic() -> UIFont? {
        return withTraits(traits: .traitItalic)
    }
    
    func withoutBold() -> UIFont? {
        guard isBold else { return self }
        var traits = fontDescriptor.symbolicTraits
        traits.remove(.traitBold)
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return nil }
        return UIFont(descriptor: descriptor, size: 0) // 0 preserves the size
    }
    
    func withoutItalic() -> UIFont? {
        guard isItalic else { return self }
        var traits = fontDescriptor.symbolicTraits
        traits.remove(.traitItalic)
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return nil }
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    private func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        let descriptor = fontDescriptor.withSymbolicTraits(traits.union(fontDescriptor.symbolicTraits))
        return descriptor != nil ? UIFont(descriptor: descriptor!, size: 0) : nil
    }
}
