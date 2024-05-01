//
//  Navigator.swift
//  ArchitectureDemo
//
//  Created by Danijel Huis on 01.05.2024..
//

import Foundation
import SwiftUI

/// Navigator manages navigation path, meaning it is responsible for pushing, popping, presenting etc., similar to UINavigationController. Its path property must be connected to NavigationStack.
public final class Navigator: ObservableObject {
    @Published var path = NavigationPath()
    
    public init() {}
    
    /// Pushes `route` using given `coordinator`.
    public func push(_ route: AppRoute, view: any View) {
        path.append(NavigationDestination(route: route, view: view))
    }
    
    /// Pops last view.
    public func pop() {
        path.removeLast()
    }
}

/// Our goal is to have single .navigationDestination call that can handle all app routes. Since .navigationDestination call takes class type as input that
/// means that we have to make wrapper class that can handle all app routes. Apple obviously didn't intend for NavigationStack to be used like this but it is very convenient.
///
/// Regarding Hashable, not sure if SwiftUI uses this for comparing views same as it does for Identifiable? In that case AppRoute.id should be constructed manually for each case.
struct NavigationDestination: Hashable {
    let route: AppRoute
    let view: any View
    
    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        lhs.route.id == rhs.route.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(route.id)
    }
}

extension AppRoute {
    var id: String { String(describing: self) }
}
