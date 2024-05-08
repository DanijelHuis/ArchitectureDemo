//
//  EffectManager.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Combine

extension Store {
    typealias ReduceClosure = @MainActor @Sendable (_ action: Action) -> Effect<Action>
    
    /// EffectManager runs effects from the store.
    ///
    /// This is separated mostly because we want the lifecycle of async operations to be independent to lifecycle of the store. If we were to run
    /// async operations in the store then store couldn't deallocate until all async effects are done (see example below). Separating this we can cancel all effects in Store's deinit.
    ///
    /// Example of deinit problem below, TestViewModel will not be able to dealloc until fetchMovies ends, weak self doesn't matter here.
    ///     ```
    ///     class TestViewModel {
    ///         init() {
    ///             Task { [weak self] in
    ///                 await self?.fetchMovies()
    ///             }
    ///         }
    ///
    ///         func fetchMovies() async {
    ///             try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
    ///         }
    ///     }
    ///     ```
    @MainActor final class EffectManager {
        
        /// Runs effect and all its chained effects. Cancelling returned task will cancel whole chain.
        ///
        /// - Parameter effect:                 Effect to run.
        /// - Parameter outputSubject:          Store's output subject for communication with the outside world (rarely needed).
        /// - Parameter reduce:                 Store's reduce function that runs reduce in reducer and returns effect.
        func runEffect(_ effect: Effect<Action>, outputSubject: PassthroughSubject<Action, Never>, reduce: @escaping ReduceClosure) -> Task<Void, Never> {
            Task {
                await runEffect(effect, outputSubject: outputSubject) { action in
                    return reduce(action)
                }
            }
        }
        
        private func runEffect(_ effect: Effect<Action>, outputSubject: PassthroughSubject<Action, Never>, reduce: ReduceClosure) async {
            guard !Task.isCancelled else { return }
            
            // Output
            if let output = effect.output {
                outputSubject.send(output)
            // Async operation
            } else if let operation = effect.operation {
                await operation { action in
                    guard !Task.isCancelled else { return }
                    let effect = await reduce(action)
                    await runEffect(effect, outputSubject: outputSubject, reduce: reduce)
                }
            }
        }
    }
}
