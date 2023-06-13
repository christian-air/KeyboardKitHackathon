//
//  DemoKeyboardView.swift
//  KeyboardTextInput
//
//  Created by Daniel Saidi on 2023-03-10.
//  Copyright © 2023 Daniel Saidi. All rights reserved.
//

import KeyboardKit
import SwiftUI

/**
 This view adds a `SystemKeyboard` and two text input fields
 to a `VStack`.

 The text fields use a custom `focused` modifier that can be
 used to also automatically show a "done" button when a text
 field receives input. As you can see, the text input fields
 use separate text and focus bindings.
 */
struct DemoKeyboardView: View {

    @State
    private var text1 = ""

    @FocusState
    private var isFocused1: Bool

    @FocusState
    private var isFocused2: Bool

    unowned var controller: KeyboardInputViewController

    var body: some View {
        
        VStack(spacing: 0) {
            Button {
                updateText()
            } label: {
                Image(systemName: "command.square.fill")
                    .foregroundColor(.green)
                Text("Expand...")
            }
            .padding()

            SystemKeyboard(
                controller: controller,
                autocompleteToolbar: .none
            )
        }.buttonStyle(.plain)
    }
    
    func updateText() {
        let currentText = controller.getAllText()
        for _ in 0 ..< currentText.composedCount {
            controller.textDocumentProxy.deleteBackward()
        }
        controller.insertText("TEST")
    }
    
    
    func doneButton() -> some View {
        Image(systemName: "x.circle.fill")
    }
}
