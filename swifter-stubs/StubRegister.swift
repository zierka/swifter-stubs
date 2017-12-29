//  Copyright © 2017 Nick Cross. All rights reserved.

import Foundation
import Swifter
import SwiftMocktail
import SwifterStubServer

class StubRegister {
    static var sharedRegister = StubRegister()

    private var stubs: [Mocktail] = []
    private let requestAuthority: RequestAuthority = RequestAuthority()
    
    func register(stub: Mocktail) {
        stubs.append( stub )
    }
    
    func remove(stub: Mocktail) {
        if let index = stubs.index(where: { $0.path == stub.path && $0.method == stub.method }) {
            stubs.remove(at: index)
        }
    }
    
    func requestHandler(request: HttpRequest) -> HttpResponse {
        var mocktail: Mocktail?
        
        for stub in stubs where requestAuthority.allowRequest(forMethod: request.method, path: request.path, withParams: request.params, withStub: stub) {
            mocktail = stub
            break
        }
        
        guard let stub = mocktail else {
            return .raw(501, "Not implemented", nil, nil)
        }
        
        defer {
            stub.variables.forEach { (key, value) in
                requestAuthority.update(variable: key, withValue: value)
            }
        }
        
        return stub.response()
    }
}
