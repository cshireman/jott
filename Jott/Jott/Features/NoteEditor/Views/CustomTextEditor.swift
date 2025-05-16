//
//  CustomTextEditor.swift
//  Jott
//
//  Created by Chris Shireman on 5/16/25.
//

import SwiftUI

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    var onSelectionChange: ((NSRange) -> Void)?
    var onTextViewCreated: ((UITextView) -> Void)?
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.text = text
        textView.delegate = context.coordinator
        
        // Notify about the created text view
        onTextViewCreated?(textView)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Only update if text changed externally to avoid cursor jumps
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor
        
        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.onSelectionChange?(textView.selectedRange)
        }
    }
}
