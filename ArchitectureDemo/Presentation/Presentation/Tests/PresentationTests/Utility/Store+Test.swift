//
//  Store+Test.swift
//  
//
//  Created by Danijel Huis on 05.05.2024..
//

import Foundation
import Uniflow
@testable import Domain

extension Store {
    func sendAndWait(_ action: Action) async {
        let task = send(action)
        await task.value
    }
}
