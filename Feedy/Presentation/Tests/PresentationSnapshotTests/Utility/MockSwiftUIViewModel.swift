//
//  MockSwiftUIViewModel.swift
//
//
//  Created by Danijel Huis on 03.06.2024..
//
import Presentation

class MockSwiftUIViewModel<State, Action>: SwiftUIViewModel {
    var effectManager = EffectManager()
    var state: State
    
    init(state: State) {
        self.state = state
    }
    
    func send(_ action: Action) {}
}

typealias MockSwiftUIViewModelOf<T: SwiftUIViewModel> = MockSwiftUIViewModel<T.State, T.Action>

