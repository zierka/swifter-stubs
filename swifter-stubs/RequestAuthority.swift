//  Copyright © 2017 Nick Cross. All rights reserved.

import Foundation
import Swifter
import SwiftMocktail

class RequestAuthority {
    private var variables: [String: String] = [:]
    
    func allowRequest(forMethod method: String, path: String, withParams params: [String: String], withStub stub: Mocktail) -> Bool {
        for (key, value) in stub.conditions {
            guard variables[key] == value else {
                return false
            }
        }
            
        return stub.canSatisfyRequest(forMethod: method, path: path, withParams: params)
    }
    
    func update(variable: String, withValue value: String) {
        variables[variable] = value
    }

}
