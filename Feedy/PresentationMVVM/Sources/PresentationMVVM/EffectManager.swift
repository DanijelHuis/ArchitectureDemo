//
//  EffectManager.swift
//  
//
//  Created by Danijel Huis on 10.06.2024..
//

import Foundation

@MainActor public final class EffectManager {
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
