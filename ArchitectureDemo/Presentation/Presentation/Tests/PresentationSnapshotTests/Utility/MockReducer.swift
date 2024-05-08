//
//  File.swift
//  
//
//  Created by Danijel Huis on 08.05.2024..
//

import Foundation
import Uniflow

typealias MockReducerOf<R: Reducer> = MockReducer<R.State, R.Action, R.InternalAction, R.Output>

class MockReducer<State, Action, InternalAction, Output>: Reducer {
    func reduce(action: Action, into state: inout State) -> Effect<Action, InternalAction, Output> {
        return .none
    }
    
    func reduce(internalAction: InternalAction, into state: inout State) -> Effect<Action, InternalAction, Output> {
        return .none
    }
}

