//
//  DemoKeyboardView.swift
//  KeyboardTextInput
//
//  Created by Daniel Saidi on 2023-03-10.
//  Copyright © 2023 Daniel Saidi. All rights reserved.
//

import KeyboardKit
import SwiftUI
import ChatGPTSwift

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
    private var text = ""
    
    @State
    private var text2 = ""

    @FocusState
    private var isFocused1: Bool

    @FocusState
    private var isFocused2: Bool

    unowned var controller: KeyboardInputViewController
    
    //AI
    let api = ChatGPTAPI(apiKey: "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")
    let persona = "a young adult"
    let tone = "friendly"
    let outputFormat = "invitation"

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
        
        text2 = currentText
        askAI()
        
        for _ in 0 ..< currentText.composedCount {
            controller.textDocumentProxy.deleteBackward()
        }
    }
    
    
    func doneButton() -> some View {
        Image(systemName: "x.circle.fill")
    }
    
    private func askAI() {
        Task {
            do {
                let stream = try await api.sendMessageStream(
                    text: text2,
                    model: "gpt-3.5-turbo",
                    systemText: getSystemText(),
                    temperature: 0.5
                )
                text = ""
                for try await line in stream {
                    text += line
                }
                
                await controller.insertText(text)
                
                
                
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
    private func getSystemText() -> String {
        return "Act as a \(persona), using \(tone) tone, generate a \(outputFormat) text based on the user's text input. You must always generate the text as if you were the user writing to someone else. Don't give advise on how to act, but only generate the text. Be expressive."
    }
    
    
}
