//
//  InputCalloutContext.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-06.
//  Copyright © 2021 Daniel Saidi. All rights reserved.
//

import SwiftUI

/**
 This context can be used to handle callouts that show a big
 version of the currently typed character.
 
 You can inherit this class and override any open properties
 and functions to customize the standard behavior.
 
 KeyboardKit automatically creates an instance of this class
 and binds it to the ``KeyboardInputViewController``.
 */
open class InputCalloutContext: ObservableObject {
    
    
    // MARK: - Initialization
    
    /**
     Create a new context instance,
     
     - Parameters:
       - isEnabled: Whether or not the context is enabled.
     */
    public init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    
    // MARK: - Properties
    
    public static let coordinateSpace = "com.keyboardkit.coordinate.InputCallout"
    
    /**
     The optional input of any currently active action.
     */
    public var input: String? { action?.inputCalloutText }
    
    /**
     Whether or not the context is enabled and has an input.
     */
    public var isActive: Bool { input != nil && isEnabled }
    
    
    // MARK: - Published Properties
    
    /**
     Whether or not the context is enabled, which means that
     it will show callouts as the user types.
     */
    @Published public var isEnabled: Bool
    
    /**
     The action that is currently active for the context.
     */
    @Published public private(set) var action: KeyboardAction?
    
    /**
     The frame of the button that is active for the context.
     */
    @Published public private(set) var buttonFrame: CGRect = .zero
    
    
    // MARK: - Functions
    
    /**
     Reset the context. This will cause any current callouts
     to be dismissed.
     */
    open func reset() {
        action = nil
        buttonFrame = .zero
    }
    
    /**
     Update the current input for a certain keyboard action.
     */
    open func updateInput(for action: KeyboardAction?, in geo: GeometryProxy) {
        self.action = action
        self.buttonFrame = geo.frame(in: .named(Self.coordinateSpace))
    }
}

public extension InputCalloutContext {
    
    /**
     Create a disabled context instance.
     */
    static var disabled: InputCalloutContext {
        InputCalloutContext(isEnabled: false)
    }
}
