//
//  AutocompleteToolbar.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-09-13.
//  Copyright © 2021 Daniel Saidi. All rights reserved.
//

import SwiftUI

/**
 This view is a horizontal row with autocomplete buttons and
 separator lines between the buttons.
 
 You can customize the button and the separator by injecting
 a custom `buttonBuilder` and/or `separatorBuilder`. You can
 also customize the `replacementAction` to determine what an
 autocomplete suggestion should do when it's tapped.
 
 Note that the views that are returned by the `buttonBuilder`
 will be nested in a button that triggers `replacementAction`.
 You should therefore only return views and not buttons when
 you provide a custom `buttonBuilder`.
 */
public struct AutocompleteToolbar: View {
    
    /**
     Create an autocomplete toolbar.
     
     - Parameters:
       - suggestions: A list of suggestions to display in the toolbar.
       - locale: The locale to apply to the toolbar.
       - itemBuilder: An optional, custom item builder. By default, the static `standardItem` will be used.
       - separatorBuilder: An optional, custom separator builder. By default, the static `standardSeparator` will be used.
       - replacementAction: An optional, custom replacement action. By default, the static `standardReplacementAction` will be used.
     */
    public init(
        suggestions: [AutocompleteSuggestion],
        locale: Locale,
        itemBuilder: @escaping ItemBuilder = Self.standardItem,
        separatorBuilder: @escaping SeparatorBuilder = Self.standardSeparator,
        replacementAction: @escaping ReplacementAction = Self.standardReplacementAction) {
        self.items = suggestions.map { BarItem($0) }
        self.itemBuilder = itemBuilder
        self.locale = locale
        self.separatorBuilder = separatorBuilder
        self.replacementAction = replacementAction
    }
    
    private let items: [BarItem]
    private let locale: Locale
    private let itemBuilder: ItemBuilder
    private let replacementAction: ReplacementAction
    private let separatorBuilder: SeparatorBuilder
    
    /**
     This internal struct is used to encapsulate item data.
     */
    struct BarItem: Identifiable {
        
        init(_ suggestion: AutocompleteSuggestion) {
            self.suggestion = suggestion
        }
        
        public let id = UUID()
        public let suggestion: AutocompleteSuggestion
    }
    
    /**
     This typealias represents the action block that is used
     to create autocomplete suggestion views, which are then
     wrapped in buttons that trigger the `replacementAction`.
     */
    public typealias ItemBuilder = (AutocompleteSuggestion, Locale) -> AnyView
    
    /**
     This typealias represents the action block that is used
     to trigger a text replacement when tapping a suggestion.
     */
    public typealias ReplacementAction = (AutocompleteSuggestion) -> Void
    
    /**
     This typealias represents the action block that is used
     to create autocomplete suggestion separator views.
     */
    public typealias SeparatorBuilder = (AutocompleteSuggestion) -> AnyView
    
    public var body: some View {
        HStack {
            ForEach(items) {
                self.view(for: $0)
            }
        }
    }
}

public extension AutocompleteToolbar {
    
    /**
     This is the default function that will be used to build
     an item view for the provided `suggestion`.
     */
    static func standardItem(for suggestion: AutocompleteSuggestion, locale: Locale) -> AnyView {
        AnyView(AutocompleteToolbarItem(
            suggestion: suggestion,
            locale: locale)
        )
    }
    
    /**
     This is the default action that will be used to trigger
     a text replacement when a `suggestion` is tapped.
     */
    static func standardReplacementAction(for suggestion: AutocompleteSuggestion) {
        let proxy = KeyboardInputViewController.shared.textDocumentProxy
        let actionHandler = KeyboardInputViewController.shared.keyboardActionHandler
        proxy.insertAutocompleteSuggestion(suggestion)
        actionHandler.handle(.tap, on: .character(""))
    }
    
    /**
     This is the default function that will be used to build
     an item separator after the provided `suggestion`.
     */
    static func standardSeparator(for suggestion: AutocompleteSuggestion) -> AnyView {
        AnyView(AutocompleteToolbarSeparator().frame(height: 30))
    }
}

private extension AutocompleteToolbar {
    
    func isLast(_ item: BarItem) -> Bool {
        item.id == items.last?.id
    }
    
    func isNextItemAutocomplete(for item: BarItem) -> Bool {
        guard let index = (items.firstIndex { $0.id == item.id }) else { return false }
        let nextIndex = items.index(after: index)
        guard nextIndex < items.count else { return false }
        return items[nextIndex].suggestion.isAutocomplete
    }
    
    func useSeparator(for item: BarItem) -> Bool {
        if item.suggestion.isAutocomplete { return false }
        if isLast(item) { return false }
        return !isNextItemAutocomplete(for: item)
    }
    
    func view(for item: BarItem) -> some View {
        let action = { self.replacementAction(item.suggestion) }
        return Group {
            Button(action: action) {
                itemBuilder(item.suggestion, locale)
            }
            .background(Color.clearInteractable)
            .buttonStyle(PlainButtonStyle())
            if useSeparator(for: item) {
                separatorBuilder(item.suggestion)
            }
        }
    }
}

struct AutocompleteToolbar_Previews: PreviewProvider {
    
    static var previews: some View {
        KeyboardInputViewController.shared = .preview
        let additionalSuggestion = StandardAutocompleteSuggestion(text: "", title: "Foo", subtitle: "Recommended")
        return VStack {
            AutocompleteToolbar(
                suggestions: previewSuggestions,
                locale: KeyboardLocale.english.locale).previewBar()
            AutocompleteToolbar(
                suggestions: previewSuggestions + [additionalSuggestion],
                locale: KeyboardLocale.spanish.locale).previewBar()
            AutocompleteToolbar(
                suggestions: previewSuggestions,
                locale: KeyboardLocale.swedish.locale,
                itemBuilder: previewItem).previewBar()
        }
        .padding()
    }
    
    static func previewItem(for suggestion: AutocompleteSuggestion, locale: Locale) -> AnyView {
        AnyView(
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    AutocompleteToolbarItemText(suggestion: suggestion, locale: KeyboardLocale.swedish.locale)
                        .font(Font.body.bold())
                    if let subtitle = suggestion.subtitle {
                        Text(subtitle).font(.footnote)
                    }
                }
                Spacer()
            }
        )
    }
    
    static let previewSuggestions: [AutocompleteSuggestion] = [
        StandardAutocompleteSuggestion("Baz", isUnknown: true),
        StandardAutocompleteSuggestion("Bar", isAutocomplete: true),
        StandardAutocompleteSuggestion(text: "", title: "Foo", subtitle: "Recommended")]
}

private extension View {
    
    func previewBar() -> some View {
        self.padding(5)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(10)
    }
}
