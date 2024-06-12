//
//  File.swift
//  
//
//  Created by Danijel Huis on 11.06.2024..
//

import Foundation
import XCTest

/// Tracks all changes to @Observable object for given keyPath.
///
/// Example:
///
///      sut.name = "0"  // This happened before tracking so it should be returned.
///      let tracker = ObservationTracker<TestViewModel, String>(...)
///      sut.name = "1"  // values stores "0"
///      sut.name = "2"  // values stores "1"
///      let values = tracker.getValues()    // returns ["1", "2"]
///      sut.name = "3"  // values stores "2"
///      sut.name = "4"  // values stores "3"
///      let values = tracker.getValues()    // returns ["3", "4"]
final class KeyPathObservationTracker<T, V> where T: AnyObject, T: Observable {
    private let object: T
    private let keyPath: KeyPath<T, V>
    private var values = [V]()
    
    init(object: T, keyPath: KeyPath<T, V>)  {
        self.object = object
        self.keyPath = keyPath
        observe()
    }
    
    @objc private func observe() {
        withObservationTracking {
            _ = object[keyPath: keyPath]
        } onChange: { [weak self] in
            guard let self else { return }
            observe()
            // IMPORTANT: This is called on willSet so this will actually store current value and not new value. This is handled later in getValues.
            values.append(object[keyPath: keyPath])
        }
    }
    
    /// Gets all changed values since init or since last `getValues` call.
    func getValues() -> [V] {
        guard !values.isEmpty else { return values }
        var values = self.values
        self.values.removeAll()
        
        // Look at the example below, first onChange will be triggered when "1" arrives, values array will store "0" because onChange is called on willSet.
        // When "2" is set values array will store "1". That means that when we call get values we will get ["0", "1"] but we should get ["1", "2"]. So to
        // work around that we remove first value and add current value, it is assumed that by the time getValues is called that runtime will exit willSet so it
        // will return actual current value.
        
        // Example:
        //      sut.name = "0"  // This happened before tracking so it should be returned.
        //      let tracker = ObservationTracker(...)
        //      sut.name = "1"  // values stores "0"
        //      sut.name = "2"  // values stores "1"
        //      let values = tracker.getValues()    // returns ["1", "2"]
        values.removeFirst()
        values.append(object[keyPath: keyPath])
        return values
    }
}

// MARK: - Tests -

final class KeyPathObservationTrackerTests: XCTestCase {
    @MainActor private var testViewModel: TestViewModel!
    private var sut: KeyPathObservationTracker<TestViewModel, String>!
    
    @MainActor override func setUp() async throws {
        testViewModel = .init()
        sut = .init(object: testViewModel, keyPath: \.name)
    }
    
    override func tearDown() {
        sut = nil
    }
    
    @MainActor func test_keyPathObservationTracker() async {
        self.testViewModel.name = "1"
        self.testViewModel.name = "2"
        self.testViewModel.name = "3"
        self.testViewModel.name = "4"
        self.testViewModel.name = "5"
        XCTAssertEqual(sut.getValues(), ["1", "2", "3", "4", "5"])
        XCTAssertEqual(sut.getValues(), [])
        XCTAssertEqual(sut.getValues(), [])
        self.testViewModel.name = "6"
        self.testViewModel.name = "7"
        XCTAssertEqual(sut.getValues(), ["6", "7"])
        self.testViewModel.name = "8"
        self.testViewModel.name = "9"
        XCTAssertEqual(sut.getValues(), ["8", "9"])
    }
}

@Observable @MainActor private class TestViewModel {
    var name: String = "initial name"
    var email: String = "initial email"
}
