//
//  View+Modifier.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import SwiftUI

extension View {
    
    /// Applies a modifier to a view.
    ///
    /// - Parameters:
    ///   - content: The modifier to apply to the view.
    /// - Returns: The modified view.
    @ViewBuilder public func modifier<T: View>(@ViewBuilder then content: (Self) -> T) -> some View {
        content(self)
    }
    
    /// Applies a modifier to a view if condition is true.
    ///
    /// - Parameters:
    ///   - condition: The condition to determine if the content should be applied.
    ///   - content: The modifier to apply to the view.
    /// - Returns: The modified view.
    @ViewBuilder public func modifier<T: View>(if condition: @autoclosure () -> Bool, @ViewBuilder then content: (Self) -> T) -> some View {
        if condition() {
            content(self)
        } else {
            self
        }
    }
    
    /// Applies a modifier to a view if value is not nil.
    ///
    /// - Parameters:
    ///   - value: The value that is tested if nil.
    ///   - content: The modifier to apply to the view.
    /// - Returns: The modified view.
    @ViewBuilder public func modifier<T: View, V>(ifLet value: V?, @ViewBuilder then content: (_ content: Self, _ value: V) -> T) -> some View {
        if let value {
            content(self, value)
        } else {
            self
        }
    }
}

