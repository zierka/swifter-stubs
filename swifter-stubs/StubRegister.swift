
//  Copyright © 2017 Nick Cross. All rights reserved.

import Foundation
import Swifter
import SwiftMocktail
import SwifterStubServer

fileprivate extension HttpRequest {
    
    fileprivate var mocktailMethod: SwiftMocktail.Method {
        guard let httpMethod = SwiftMocktail.HttpMethod(rawValue: method) else {
            return .other(method)
        }
        
        return .httpMethod(httpMethod)
    }
    
}

fileprivate extension Mocktail {
    
    private var data: Data? {
        return responseBody.data(using: .utf8)
    }
    
    fileprivate func request() -> StubRequest {
        //todo: params should extracted from query string..??
        return StubRequest(method: method, path: path, params: [:])
    }
    
    fileprivate func response() -> HttpResponse {
        return HttpResponse.raw(responseStatusCode, "Stubbed response", responseHeaders) { responseBodyWriter in
            guard let data = self.data else { return }
            try responseBodyWriter.write(data)
        }
    }
}

fileprivate struct StubRequest: Hashable, Equatable {
    let method: SwiftMocktail.Method
    let path: String
    let params: [String:String]
    
    var hashValue: Int {
        return method.hashValue ^ params.keys.reduce(path.hashValue, { return $0 ^ $1.hashValue } )
    }
    
    static func ==(lhs: StubRequest, rhs: StubRequest) -> Bool {
        return lhs.method == rhs.method && lhs.path == rhs.path && lhs.params == rhs.params
    }
}

class StubRegister {
    static var sharedRegister = StubRegister()

    private var stubs: [StubRequest: Mocktail] = [:]
    
    func register(stub: Mocktail) {
        stubs[stub.request()] = stub
    }
    
    func remove(stub: Mocktail) {
        stubs[stub.request()] = nil
    }
    
    func requestHandler(request: HttpRequest) -> HttpResponse {
        let stubRequest = StubRequest(method:request.mocktailMethod, path: request.path, params: request.params)
    
        guard let mocktail = stubs[stubRequest] else {
            return .raw(501, "Not implemented", nil, nil)
        }
        
        return mocktail.response()
    }
}
