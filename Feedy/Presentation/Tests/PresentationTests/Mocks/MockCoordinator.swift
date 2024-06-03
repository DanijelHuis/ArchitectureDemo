//
//  MockCoordinator.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation
import Presentation
import TestUtility

final class MockCoordinator: Coordinator {
    var openRouteCalls = [AppRoute]()
    func openRoute(_ route: Presentation.AppRoute) {
        openRouteCalls.append(route)
    }    
}

