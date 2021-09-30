//
//  InputCalloutContext.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-06.
//  Copyright © 2021 Daniel Saidi. All rights reserved.
//

import SwiftUI

/**
 This context can be used to handle input callouts that show
 the currently typed character.
 
 `KeyboardKit` will automatically create an instance of this
 class and bind it to the input view controller. The default
 instance will only be enabled for iPhones.
 */
public class InputCalloutContext: ObservableObject {
    
    
    // MARK: - Initialization
    
    public init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    
    // MARK: - Properties
    
    static let coordinateSpace = "com.keyboardkit.coordinate.InputCallout"
    
    /**
     The optional input of any currently active action.
     */
    public var input: String? { action?.inputCalloutText }
    
    /**
     Whether or not the context is enabled and has an input.
     */
    public var isActive: Bool { input != nil && isEnabled }
    
    /**
     Whether or not the context is enabled, which means that
     it will show callouts as the user types.
     */
    @Published public var isEnabled: Bool
    
    /**
     The action that is currently active for the context.
     */
    @Published private(set) var action: KeyboardAction?
    
    /**
     The frame of the button that is active for the context.
     */
    @Published private(set) var buttonFrame: CGRect = .zero
    
    
    // MARK: - Functions
    
    /**
     Update the current input for a certain keyboard action.
     */
    public func register(_ action: KeyboardAction?, in geo: GeometryProxy) {
        self.action = action
        self.buttonFrame = geo.frame(in: .named(Self.coordinateSpace))
    }
    
    /**
     Reset the context. This will cause any current callouts
     to be dismissed.
     */
    public func reset() {
        action = nil
        buttonFrame = .zero
    }
}
