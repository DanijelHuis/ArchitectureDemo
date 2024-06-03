//
//  SwiftUIViewModel.swift
//
//
//  Created by Danijel Huis, Ben Rosen, Byron Cooke
//

import Foundation
import Combine
import SwiftUI

/// Base ViewModel to support MVI architecture
@MainActor public protocol SwiftUIViewModel<State, Action>: ObservableObject {
    associatedtype State
    associatedtype Action
    
    /// Current State. Implementations should mark it with @Published.
    var state: State { get }
    /// Effect manager's responsibility is to run all async tasks. This separation is convenient for testing but also for waiting all tasks to finish.
    var effectManager: SideEffectManager { get }
    /// Sends action to view model.
    func send(_ action: Action)
}

extension SwiftUIViewModel {
    /// Sends action and waits all tasks to finish. Use this only when really needed. In unidirectional architecture we usually don't need to wait for send action to finish because view should simply observe the state. There are few exceptions where it is
    /// convenient to wait, e.g. in .refreshable.
    func sendAsync(_ action: Action) async {
        send(action)
        await effectManager.wait()
    }
}

// MARK: - ObservableSwiftUIViewModel -

/// The purpose of this is:
/// - our goal is to cancel all async tasks when view deallocates, also we want to be able to make async tasks without [weak self].
///   Having proxy class that holds reference to view model will allow us just that, proxy isn't held by async functions so it will receive deinit when
///   view deallocates, in that deinit we can cancel all async actions (viewModel.effectManager.cancel()).
/// - We cannot declare protocol that is @ObservedObject, e.g. this won't work:
///   @ObservedObject let viewModel: any SwiftUIViewModel<SomeState, SomeAction>
///   So to avoid it we make proxy class. Without this we would have to make View generic which is unnecessary complication.
@MainActor
public class ObservableSwiftUIViewModel<State, Action>: ObservableObject {
    private let viewModel: any SwiftUIViewModel<State, Action>
    private var cancellables: Set<AnyCancellable> = []
    
    public init<T: SwiftUIViewModel<State, Action>>(viewModel: T) {
        self.viewModel = viewModel

        viewModel.objectWillChange.sink { [weak self] value in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    deinit {
        Task { @MainActor [viewModel = self.viewModel] in
            viewModel.effectManager.cancel()
        }
    }
    
    // MARK: - Proxying -
    
    // Note: We could use @dynamicMemberLookup instead but that reveals little bit too much.
    var state: State { viewModel.state }
    func send(_ action: Action) { viewModel.send(action) }
    func sendAsync(_ action: Action) async { await viewModel.sendAsync(action) }
}

public typealias ObservableSwiftUIViewModelOf<ViewModel: SwiftUIViewModel> = ObservableSwiftUIViewModel<ViewModel.State, ViewModel.Action>

extension ObservableSwiftUIViewModel {
    func binding<T>(_ keyPath: KeyPath<State, T>, send actionClosure: @escaping (T) -> Action) -> Binding<T> {
        Binding<T>(
            get: { self.state[keyPath: keyPath] },
            set: {
                let action = actionClosure($0)
                self.send(action)
            })
    }
}

// MARK: - EffectManager -

@MainActor public final class SideEffectManager {
    private var tasks = [String: Task<Void, Never>]()
    
    public init() {}
    
    /// Creates new task and runs closure in it. Stores tasks so we can wait for it if needed.
    @discardableResult func run(id: String = UUID().uuidString, closure: @escaping () async -> Void) -> Task<Void, Never> {
        let task = Task {
            await closure()
            tasks[id] = nil
        }
        tasks[id] = task
        return task
    }
    
    /// Waits until all tasks are finished.
    func wait() async {
        await withTaskCancellationHandler {
            // Note: this will not "run" tasks one after another, it will just wait until all are done. These tasks are running concurrently.
            for task in tasks.values {
                await task.value
            }
        } onCancel: {
            Task {
                await cancel()
            }
        }
    }
    
    func cancel() {
        tasks.values.forEach({ $0.cancel() })
        tasks.removeAll()
    }
}
