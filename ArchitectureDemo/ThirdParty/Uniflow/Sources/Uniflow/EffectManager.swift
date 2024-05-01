//
//  EffectManager.swift
//
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import Combine

extension Store {
    typealias ReduceClosure = @MainActor @Sendable (_ actionAndInternalAction: ActionAndInternalAction<Action, InternalAction>) -> Effect<Action, InternalAction, Output>
    
    /// EffectManager runs effects from the store.
    ///
    /// The most important part why this is separated is because we want the lifecycle of async operations to be independent to lifecycle of a store. If we were to run
    /// async operations in the store then store couldn't deallocate until all async effects are done (see example below). Separating this we can cancel all effects in Store's deinit.
    ///
    /// Example of this problem below, TestViewModel will not be able to dealloc until fetchMovies ends, weak self doesn't matter here.
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
        /// - Parameter outputSubject:          Store's output subject, used to send output if effect has one.
        /// - Parameter reduce:                 Store's reduce function that runs reduce in reducer and returns effect.
        func runEffect(_ effect: Effect<Action, InternalAction, Output>, outputSubject: PassthroughSubject<Output, Never>, reduce: @escaping ReduceClosure) -> Task<Void, Never> {
            Task {
                await runEffect(effect, outputSubject: outputSubject) { actionAndInternalAction in
                    return reduce(actionAndInternalAction)
                }
            }
        }
        
        private func runEffect(_ effect: Effect<Action, InternalAction, Output>, outputSubject: PassthroughSubject<Output, Never>, reduce: ReduceClosure) async {
            guard !Task.isCancelled else { return }
            
            // Output
            if let output = effect.output {
                outputSubject.send(output)
                // Async operation
            } else if let operation = effect.operation {
                await operation { actionAndInternalAction in
                    guard !Task.isCancelled else { return }
                    let effect = await reduce(actionAndInternalAction)
                    await runEffect(effect, outputSubject: outputSubject, reduce: reduce)
                }
            }
        }
    }
}
