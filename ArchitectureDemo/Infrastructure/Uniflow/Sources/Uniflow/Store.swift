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
/// - Parameter InternalAction:     State can be changed only by sending an action but not all actions need to be public, some are internal to the reducer, that is why this exists.
/// - Parameter Output:             Can be used for one-shot events. This is more convenient than trying to emulate events by manipulating state (e.g. setting shouldShowAlert to true and false).
@MainActor
public class Store<State, Action, InternalAction, Output>: ObservableObject where Action: Sendable, InternalAction: Sendable {
    @Published public private(set) var state: State
    
    private let reducer: any Reducer<State, Action, InternalAction, Output>
    private let outputSubject: PassthroughSubject<Output, Never> = .init()
    private var effectManager = EffectManager()
    private var effectTasks = [Task<Void, Never>]()
    
    public init(state: State, reducer: some Reducer<State, Action, InternalAction, Output>) {
        self.state = state
        self.reducer = reducer
    }
    
    deinit {
        effectTasks.forEach({ $0.cancel() })
    }
    
    // MARK: - send/reduce -
    
    @discardableResult public func send(_ action: Action) -> Task<Void, Never> {
        let effect = reduce(actionAndInternalAction: .action(action))
        let task = effectManager.runEffect(effect, outputSubject: outputSubject) { [weak self] actionAndInternalAction in
            guard let self else { return .none }
            return self.reduce(actionAndInternalAction: actionAndInternalAction)
        }
        effectTasks.append(task)
        return task
    }
    
    private func reduce(actionAndInternalAction: ActionAndInternalAction<Action, InternalAction>) -> Effect<Action, InternalAction, Output> {
        switch actionAndInternalAction {
        case .action(let action):
            return self.reducer.reduce(action: action, into: &self.state)
        case .internalAction(let internalAction):
            return self.reducer.reduce(internalAction: internalAction, into: &self.state)
        }
    }
}

// MARK: - Effect -

public struct Effect<Action, InternalAction, Output> {
    public typealias Operation = (@Sendable (_ actionAndInternalAction: ActionAndInternalAction<Action, InternalAction>) async -> Void) async -> Void
    let output: Output?
    let operation: Operation?
    
    private init(output: Output?, operation: Operation?) {
        self.output = output
        self.operation = operation
    }
    
    public static var none: Self {
        .init(output: nil, operation: nil)
    }
    
    public static func output(_ output: Output) -> Self {
        .init(output: output, operation: nil)
    }
    
    public static func run(operation: @escaping Operation) -> Self {
        .init(output: nil, operation: operation)
    }
}

// MARK: - Reducer -

@MainActor
public protocol Reducer<State, Action, InternalAction, Output>: AnyObject {
    associatedtype State
    associatedtype Action
    associatedtype InternalAction = Never
    associatedtype Output = Never
    
    func reduce(action: Action, into state: inout State) -> Effect<Action, InternalAction, Output>
    func reduce(internalAction: InternalAction, into state: inout State) -> Effect<Action, InternalAction, Output>
}

extension Reducer where InternalAction == Never {
    /// If InternalAction is Never then we can provide default implementation for internal reducer.
    public func reduce(internalAction: InternalAction, into state: inout State) -> Effect<Action, InternalAction, Output> { }
}

// MARK: - Support -

public enum ActionAndInternalAction<Action, InternalAction>: Sendable where Action: Sendable, InternalAction: Sendable {
    case action(Action)
    case internalAction(InternalAction)
}

public typealias StoreOf<R: Reducer> = Store<R.State, R.Action, R.InternalAction, R.Output>
