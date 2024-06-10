//
//  Comparable.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation

// Sorts desscending by putting nil at the end.
infix operator >>> : DefaultPrecedence
public func >>> <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let(lhs?, rhs?): return lhs > rhs  // Both lhs and rhs are not nil
    case (nil, _): return false             // Lhs is nil
    case (_?, nil): return true             // Lhs is not nil, rhs is nil
    }
}

// Sorts ascending by putting nil at the end.
infix operator <<< : DefaultPrecedence
public func <<< <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let(lhs?, rhs?): return lhs < rhs  // Both lhs and rhs are not nil
    case (nil, _): return false             // Lhs is nil
    case (_?, nil): return true             // Lhs is not nil, rhs is nil
    }
}
