//
//  InputSetProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-12-01.
//  Copyright © 2021 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented by any classes that can be
 used to provide ``InputSet`` values for keyboard layouts.
 
 An ``InputSet`` defines the input keys on a system keyboard.
 The keys can then be used to create a layout, which defines
 the full set of keys, including the surrounding system keys.
 
 KeyboardKit automatically creates an implementation of this
 protocol and binds it to ``KeyboardInputViewController``.
 */
public protocol InputSetProvider: AnyObject {
    
    /**
     The input set to use for alphabetic keyboards.
     */
    var alphabeticInputSet: AlphabeticInputSet { get }

    /**
     The input set to use for numeric keyboards.
     */
    var numericInputSet: NumericInputSet { get }

    /**
     The input set to use for symbolic keyboards.
     */
    var symbolicInputSet: SymbolicInputSet { get }
}