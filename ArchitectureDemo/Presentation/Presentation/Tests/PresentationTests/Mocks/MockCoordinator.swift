//
//  MockCoordinator.swift
//
//
//  Created by Danijel Huis on 05.05.2024..
//

import Foundation
@testable import Presentation

final class MockCoordinator: Coordinator {
    var openRouteCalls = [AppRoute]()
    func openRoute(_ route: AppRoute) {
        openRouteCalls.append(route)
    }
}
