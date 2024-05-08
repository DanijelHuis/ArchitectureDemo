//
//  Store.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//  Heavily inspired by: https://betterprogramming.pub/different-flavors-of-unidirectional-architectures-in-swift-781a01380ef6

import Foundation
import Combine

// MARK: - Store -

/// Store.
///
/// Cancellation: You don't have to use [weak self] in reduce functions when returning operation because Store is independent from reducer and will be deallocated no matter if reducer keeps self.
/// When store is deallocated it will explicitly cancel all effects.
///
/// - Parameter State:              State that holds all data that feature needs.
/// - Parameter Action:             Outside world can send actions to the store to request changes to the state.
@MainActor
public class Store<State, Action>: ObservableObject where Action: Sendable {
    @Published public private(set) var state: State
    
    private let reducer: any Reducer<State, Action>
    private let outputSubject: PassthroughSubject<Action, Never> = .init()
    private var effectManager = EffectManager()
    private var effectTasks = [Task<Void, Never>]()
    
    public init(state: State, reducer: some Reducer<State, Action>) {
        self.state = state
        self.reducer = reducer
    }
    
    deinit {
        effectTasks.forEach({ $0.cancel() })
    }
    
    // MARK: - send/reduce -
    
    @discardableResult public func send(_ action: Action) -> Task<Void, Never> {
        let effect = reduce(action: action)
        let task = effectManager.runEffect(effect, outputSubject: outputSubject) { [weak self] effectAction in
            guard let self else { return .none }
            return self.reduce(action: effectAction)
        }
        effectTasks.append(task)
        return task
    }
    
    private func reduce(action: Action) -> Effect<Action> {
        return self.reducer.reduce(action: action, into: &self.state)
    }
}

// MARK: - Effect -

public struct Effect<Action> {
    public typealias Operation = (@Sendable (_ action: Action) async -> Void) async -> Void
    let output: Action?
    let operation: Operation?
    
    private init(output: Action?, operation: Operation?) {
        self.output = output
        self.operation = operation
    }
    
    public static var none: Self {
        .init(output: nil, operation: nil)
    }
    
    public static func output(_ output: Action) -> Self {
        .init(output: output, operation: nil)
    }
    
    public static func run(operation: @escaping Operation) -> Self {
        .init(output: nil, operation: operation)
    }
}

// MARK: - Reducer -

@MainActor
public protocol Reducer<State, Action>: AnyObject {
    associatedtype State
    associatedtype Action

    func reduce(action: Action, into state: inout State) -> Effect<Action>
}

// MARK: - Support -

public typealias StoreOf<R: Reducer> = Store<R.State, R.Action>
