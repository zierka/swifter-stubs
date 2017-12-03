//  Copyright © 2017 Nick Cross. All rights reserved.


import Foundation
import Swifter
import SwiftMocktail

public protocol HttpStubServer {
    func enableStub(forFile path: String) throws
    func disableStub(forFile path: String) throws
    
    func startStubServer(onPort port: in_port_t) throws
    func stopStubServer()
}

enum HttpStubServerError: Error {
    case invalidStubFile
}

extension HttpServer: HttpStubServer {
    
    public func startStubServer(onPort port: in_port_t) throws {
        try start(port, forceIPv4: false, priority: .default)
    }
    
    public func stopStubServer() {
        stop()
    }
    
    public func enableStub(forFile path: String) throws {
        let stubDefinition: Mocktail = try loadStub(fromFile: path)
        self[stubDefinition.path] = stubRegister.requestHandler
    }
    
    public func disableStub(forFile path: String) throws {
        let stubDefinition: Mocktail = try loadStub(fromFile: path)
        self[stubDefinition.path] = nil
    }

    // MARK: - Private
    
    private func loadStub(fromFile path: String) throws -> Mocktail {
        do {
            return try Mocktail(path: path)
        }
        catch let error where error is MocktailError {
            throw HttpStubServerError.invalidStubFile
        }
    }
    
}

private let stubRegister = StubRegister()

fileprivate extension HttpRequest {
    
    fileprivate var mocktailMethod: SwiftMocktail.Method {
        guard let httpMethod = SwiftMocktail.HttpMethod(rawValue: method) else {
            return .other(method)
        }
        
        return .httpMethod(httpMethod)
    }
    
}

fileprivate extension Mocktail {
    
    fileprivate var data: Data? {
        return responseBody.data(using: .utf8)
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
         return params.keys.reduce(path.hashValue, { return $0 + $1.hashValue } )
    }
    
    static func ==(lhs: StubRequest, rhs: StubRequest) -> Bool {
        return lhs.path == rhs.path && lhs.params == rhs.params
    }
}

fileprivate class StubRegister {
    fileprivate let stubs: [StubRequest: Mocktail] = [:]
    
    fileprivate let requestHandler: ((HttpRequest) -> HttpResponse) = { request in
        let stubRequest = StubRequest(method:request.mocktailMethod, path: request.path, params: request.params)
        
        guard let mocktail = stubRegister.stubs[stubRequest] else {
            return .raw(501, "Not implemented", nil, nil)
        }
        
        return mocktail.response()
    }
}
