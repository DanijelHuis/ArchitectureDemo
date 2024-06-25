//
//  MockCoordinator.swift
//
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation
import PresentationMVI
import TestUtility
import CommonUI

final class MockCoordinator: Coordinator {
    var openRouteCalls = [AppRoute]()
    func openRoute(_ route: AppRoute) {
        openRouteCalls.append(route)
    }    
}

