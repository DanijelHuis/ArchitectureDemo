//
//  EffectManager.swift
//  
//
//  Created by Danijel Huis on 10.06.2024..
//

import Foundation

/// Helper class for managing tasks. It allows us to spawn, wait and cancel tasks.
/// It will automatically cancel all tasks and streams when deinited.
@MainActor public final class EffectManager {
    private var tasks = [String: TaskData]()
    
    public init() {}
    
    deinit {
        /// Cancelling all tasks and streams.
        Task { @MainActor [tasks = tasks] in
            tasks.values.forEach({ $0.task.cancel() })
        }
    }
    
    // MARK: - Main logic -
    
    @discardableResult private func run(id: String, type: TaskType, closure: @escaping () async -> Void) -> Task<Void, Never> {
        let task = Task { [weak self] in
            await closure()
            self?.tasks[id] = nil
        }
        tasks[id] = .init(id: id, task: task, type: type)
        return task
    }
    
    private func cancelTasks(type: TaskType) {
        for (key, task) in tasks {
            guard task.type == type else { continue }
            task.task.cancel()
            tasks[key] = nil    // This is OK, we can mutate while iterating.
        }
    }
    
    // MARK: - Tasks -
    
    /// Spawns tasks and runs closure in it. Task is stored so it can be waited on and cancelled.
    /// For streams better use runStream, that way when we call wait it will wait only non-stream tasks (we don't want to wait on indefinite streams).
    @discardableResult public func runTask(id: String = UUID().uuidString, closure: @escaping () async -> Void) -> Task<Void, Never> {
        run(id: id, type: .task, closure: closure)
    }
    
    /// Cancels all tasks, doesn't cancel streams.
    public func cancelTasks() {
        cancelTasks(type: .task)
    }
    
    /// Waits until all tasks are finished.
    public func wait() async {
        await withTaskCancellationHandler {
            // Note: this will not "run" tasks one after another, it will just wait until all are done. These tasks are running concurrently.
            for task in tasks.values.filter({ $0.type == .task }).map({ $0.task }) {
                await task.value
            }
        } onCancel: {
            Task {
                await cancelTasks()
            }
        }
    }
    
    // MARK: - Streams -
    
    /// Spawns tasks and runs closure in it. Task is stored so it can be cancelled.
    /// This is the same as runTask but it is marked as stream so when we call `wait`, we don't wait for indefinite streams to finish.
    @discardableResult public func runStream(id: String = UUID().uuidString, closure: @escaping () async -> Void) -> Task<Void, Never> {
        run(id: id, type: .stream, closure: closure)
    }
    
    /// Cancels all streams.
    public func cancelStreams() {
        cancelTasks(type: .stream)
    }
}

// MARK: - Support -

private struct TaskData {
    let id: String
    let task: Task<Void, Never>
    let type: TaskType
}

private enum TaskType {
    case task
    case stream
}
