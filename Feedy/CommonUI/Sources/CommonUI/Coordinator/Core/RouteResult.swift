//
//  RouteResult.swift
//  
//
//  Created by Danijel Huis on 20.05.2024..
//

import Foundation
import SwiftUI
import UIKit

public enum RouteResult {
    case push(view: any View)
    case present(controller: UIViewController, animated: Bool)
    case none
}
