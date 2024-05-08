//
//  File.swift
//  
//
//  Created by Danijel Huis on 08.05.2024..
//

import Foundation
import Uniflow

typealias MockReducerOf<R: Reducer> = MockReducer<R.State, R.Action>

class MockReducer<State, Action>: Reducer {
    func reduce(action: Action, into state: inout State) -> Effect<Action> {
        return .none
    }
}

