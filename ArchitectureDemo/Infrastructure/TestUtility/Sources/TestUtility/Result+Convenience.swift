//
//  Result+Convenience.swift
//
//
//  Created by Danijel Huis on 04.05.2024..
//

import Foundation

extension Result {
    public var success: Success? {
        guard case let .success(object) = self else { return nil }
        return object
    }
    
    public var failure: Failure? {
        guard case let .failure(error) = self else { return nil }
        return error
    }
}
