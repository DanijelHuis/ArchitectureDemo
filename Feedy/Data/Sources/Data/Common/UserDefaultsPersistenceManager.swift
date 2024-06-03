//
//  UserDefaultsPersistenceManager.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import Foundation

/// Implements `PersistenceManager` on top of UserDefaults. Thread safe.
public class UserDefaultsPersistenceManager: PersistenceManager {
    private let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func save<T: Encodable>(_ object: T, forKey key: String) throws {
        try userDefaults.saveCodable(object, forKey: key)
    }
    
    public func load<T: Decodable>(key: String, type: T.Type) throws -> T? {
        try userDefaults.loadCodable(key: key)
    }
}

private extension UserDefaults {
    /// Saves Codable value to user defaults.
    func saveCodable<T: Encodable>(_ value: T, forKey key: String, encoder: JSONEncoder = JSONEncoder()) throws {
        let data: Data = try encoder.encode(value)
        self.set(data, forKey: key)
    }
    
    /// Loads Codable value from user defaults.
    func loadCodable<T: Decodable>(key: String, decoder: JSONDecoder = JSONDecoder()) throws -> T? {
        guard let data = self.data(forKey: key) else { return nil }
        return try decoder.decode(T.self, from: data)
    }
}
