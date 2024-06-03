//
//  PersistenceManager.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation

public protocol PersistenceManager {
    func save<T: Encodable>(_ object: T, forKey: String) throws
    func load<T: Decodable>(key: String, type: T.Type) throws -> T?
}
