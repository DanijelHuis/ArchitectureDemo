//
//  XCTestCase+Utility.swift
//  
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation
import SwiftUI
import XCTest

extension XCTestCase {
    func host(_ view: some View) -> UIViewController {
        return UIHostingController(rootView: view)
    }
}
