//
//  HomeScreen.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-11.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import ChatGPTSwift
import KeyboardKit
import SwiftUI

/**
 This is the main demo app screen.

 This screen has a text field, an appearance toggle and list
 items that show various keyboard-specific states.

 This app has many keyboards, where `Keyboard` shows you how
 to setup a standard, English keyboard with some adjustments.

 `KeyboardCustom` has a custom input set and keyboard layout,
 as well as a custom appearance.

 `KeyboardTextInput` shows how to setup a keyboard with text
 fields and text views, to enable text input in the keyboard.

 `KeyboardUnicode` shows how to setup a keyboard that uses a
 unicode-based input set for its input keys.

 `KeyboardPro` is a KeyboardKit Pro-powered keyboard that is
 using KeyboardKit Pro instead of KeyboardKit. It will setup
 all supported locales, dictation etc., as well as dictation,
 (although that feature is not fully working, since it needs
 a properly signed app). Take a look at this pro keyboard to
 see how to set up KeyboardKit Pro.
 */
struct HomeScreen: View {
    let api = ChatGPTAPI(apiKey: "CHANGE-API-KEY")

    @State
    private var appearance = ColorScheme.light

    @State
    private var isAppearanceDark = false

    @State
    private var text = ""

    @StateObject
    private var dictationContext = DictationContext(config: .app)

    @StateObject
    private var keyboardState = KeyboardEnabledState(
        bundleId: "com.keyboardkit.demo.*")

    var body: some View {
        NavigationView {
            
            VStack {
                List {
                    textFieldSection
                    testButton
                    profiles
                    stateSection
                }
                .buttonStyle(.plain)
                .navigationTitle("TextMate")
                .onChange(of: isAppearanceDark) { newValue in
                    appearance = isAppearanceDark ? .dark : .light
                }
                
            }
        }
        .navigationViewStyle(.stack)
        .onOpenURL { _ in print("WARNING: Keyboard dictation requires KeyboardKit Pro and a signed app group") }
        /**
         This view modifier is available in KeyboardKit Pro.
         .keyboardDictation(context: dictationContext, config: .app) {
             DictationScreen(
                 dictationContext: dictationContext,
                 titleView: { EmptyView() },
                 indicator: { DictationBarVisualizer(isDictating: $0) }
             )
         }
         */
    }
}

extension HomeScreen {

    var textFieldSection: some View {
        Section(header: Text("Test your text with TextMate")) {
            TextEditor(text: $text)
                .frame(height: 100)
                .keyboardAppearance(appearance)
        }
    }
    
    var profiles: some View {
        Section(header: Text("Profiles")) {

            NavigationLink(destination: Text("Text Type")) {
                Image(systemName: "person.3")
                Text("Persona")
            }
            NavigationLink(destination: Text("Audience")) {
                Image(systemName: "person.3")
                Text("Tone")
            }
            NavigationLink(destination: Text("Text Type")) {
                Image(systemName: "person.3")
                Text("Length")
            }
        }
    }
    
    
    var testButton: some View {
        VStack {
            Button {
                askAI()
            } label: {
                Text("Test your Text Mate")
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .listRowInsets(.init())
        .listRowBackground(Color.clear)
        .padding(.horizontal)
    }

    var editorLinkSection: some View {
        Section(header: Text("Editor")) {
            NavigationLink {
                TextEditor(text: $text)
                    .padding(.horizontal)
                    .navigationTitle("Editor")
            } label: {
                Label {
                    Text("Full screen editor")
                } icon: {
                    Image(systemName: "doc.text")
                }
            }
        }
    }
    
    private func askAI() {
        Task {
            do {
                let stream = try await api.sendMessageStream(
                    text: text,
                    model: "gpt-3.5-turbo",
                    systemText: "Act as a {{persona}}, using a {{tone}} tone and starting with the users input, generate a {{output}} text to help the user write the text they want. You must always generate the text as if you were the user writing it while texting to someone else. Don't give advise on how to act, but only generate the text.",
                    temperature: 0.5
                )
                text = ""
                for try await line in stream {
                    text += line
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    var stateSection: some View {
        Section(header: Text("Keyboard"), footer: footerText) {
            KeyboardEnabledLabel(
                isEnabled: keyboardState.isKeyboardActive,
                enabledText: "Demo keyboard is active",
                disabledText: "Demo keyboard is not active"
            )
            KeyboardSettingsLink(addNavigationArrow: true) {
                KeyboardEnabledLabel(
                    isEnabled: keyboardState.isKeyboardEnabled,
                    enabledText: "Demo keyboard is enabled",
                    disabledText: "Demo keyboard not enabled"
                )
            }
            KeyboardSettingsLink(addNavigationArrow: true) {
                KeyboardEnabledLabel(
                    isEnabled: keyboardState.isFullAccessEnabled,
                    enabledText: "Full Access is enabled",
                    disabledText: "Full Access is disabled"
                )
            }
        }
    }
    
    var footerText: some View {
        Text("You must enable the keyboard in System Settings, then select it with 🌐 when typing.")
    }
    

    var isRtl: Bool {
        let keyboardId = keyboardState.activeKeyboardBundleIds.first
        return keyboardId?.hasSuffix("rtl") ?? false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
