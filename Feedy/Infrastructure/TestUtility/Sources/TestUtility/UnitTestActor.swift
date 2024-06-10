//
//  UnitTestActor.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation

/// Mark your XCTestCase class and mock dependencies with this actor in order to synchronize access to properties of the mock.
/// This is needed when you run multiple async actions in parallel from your test case (e.g. testing TaskGroup), following problems are possible:
/// - multiple tasks writing to some property on the mock, this results in crash
/// - task reading property that is being changed by other task at the same time which means you get "wrong" result
/// - if functions of your test case and your mock are not performed on the same actor then you must take into account that some properties on the
///   mock can change in the middle of your function (on test case), e.g. if you run guard check of some mock property at start of the function,
///   that mock property can change between guard check and body of that same function.
///
/// Note: Problems described above are rare but they happen if you run test repeatedly 10000 times.
/// Note2: We can also use MainActor to sync XCTestCase and mocks but waitUntil function sometimes blocks main actor.
@globalActor public actor UnitTestActor {
    public static let shared = UnitTestActor()
}
