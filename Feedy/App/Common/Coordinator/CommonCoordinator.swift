//
//  CommonCoordinator.swift
//  Feedy
//
//  Created by Danijel Huis on 19.05.2024..
//

import Foundation
import UIKit
import SafariServices
import SwiftUI
import CommonUI

@MainActor struct CommonCoordinator {
    init() {}
    
    func view(_ route: CommonRoute, navigator: Navigator) -> RouteResult {
        switch route {
        case .safari(let url):
            let controller = SFSafariViewController(url: url)
            return .present(controller: controller, animated: true)
        }
    }
}
