
//  Copyright © 2017 Nick Cross. All rights reserved.

import Foundation
import Swifter
import SwiftMocktail
import SwifterStubServer

fileprivate enum StubHeaders: String {
    case onlyIf = "stub-only-if"
    case set = "stub-set"
    case delay = "stub-delay"

    var header: String {
        return rawValue
    }
    
    static func isStubHeader(header: String) -> Bool {
        return [StubHeaders.onlyIf.header, StubHeaders.set.header, StubHeaders.delay.header].contains(header)
    }
}

fileprivate extension HttpRequest {
    
    fileprivate var mocktailMethod: SwiftMocktail.Method {
        guard let httpMethod = SwiftMocktail.HttpMethod(rawValue: method) else {
            return .other(method)
        }
        
        return .httpMethod(httpMethod)
    }
    
}

fileprivate extension Mocktail {
    fileprivate func canSatisfy(request: HttpRequest) -> Bool {
        guard SwiftMocktail.Method.other(request.method) == method else {
            return false
        }
        
        guard let expression = try? NSRegularExpression(pattern:"^\(partialPath)$", options: .caseInsensitive) else {
            fatalError("Failed to create regular expression from partial path: \(partialPath)")
        }

        guard expression.firstMatch(in: request.path, options: [], range: NSMakeRange(0,request.path.count)) != nil else {
            return false
        }

        for case let param in params.keys where request.params[param] != params[param] {
            return false
        }
        
        return true
    }
    
    fileprivate func response() -> HttpResponse {
        let headers = responseHeaders.filter { header, _ -> Bool in
            return !StubHeaders.isStubHeader(header: header)
        }
        
        return HttpResponse.raw(responseStatusCode, "Stubbed response", headers) { responseBodyWriter in
            guard let data = self.data else { return }
            let delay: Double = self.delay ?? 0.5
            
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + delay) {
                try? responseBodyWriter.write(data)
            }
        }
    }
    
    fileprivate var variables: [String: String] {
        guard let setHeader = responseHeaders[StubHeaders.set.header] else {
            return [:]
        }
        
        return setHeader.asPropertyDictionary()
    }

    fileprivate var conditions: [String:String] {
        guard let onlyIfHeader = responseHeaders[StubHeaders.onlyIf.header] else {
            return [:]
        }
        
        return onlyIfHeader.asPropertyDictionary()
    }

    private var delay: Double? {
        guard let delayString: String = responseHeaders[StubHeaders.delay.header] else {
            return nil
        }

        return Double(delayString)
    }

    private var data: Data? {
        return responseBody.data(using: .utf8)
    }
    
    private var params: [String: String] {
        guard let queryStringOnly = path.components(separatedBy:"\\?").last else {
            return [:]
        }
        
        guard let queryItems = NSURLComponents(string: "?\(queryStringOnly)" )?.queryItems else {
            return [:]
        }
        
        var queryParams: [String:String] = [:]
        
        for item in queryItems {
            queryParams[item.name] = item.value
        }
        
        return queryParams
    }
    
    private var partialPath: String {
        //raw expression (((?!\\\?).)+)\\\?.*
        //the first group of a match will be the string prior to the escaped question mark
        guard let expression = try? NSRegularExpression(pattern: "(((?!\\\\\\?).)+)\\\\\\?.*", options: .caseInsensitive) else {
            fatalError("The expression is invalid")
        }
        
        if let rangeOfPath = expression.firstMatch(in: path, options: [.anchored], range: NSMakeRange(0, path.count))?.range(at: 1),
            let range = Range(rangeOfPath, in: path) {
            return String(path[range])
        }
        
        guard let path = NSURLComponents(string: path)?.path else {
            fatalError("Invalid path: \(self.path)")
        }
        
        return path
    }

}

class StubRegister {
    static var sharedRegister = StubRegister()

    private var stubs: [Mocktail] = []
    private var variables: [String: String] = [:]
    
    func register(stub: Mocktail) {
        stubs.append( stub )
    }
    
    func remove(stub: Mocktail) {
        if let index = stubs.index(where: { $0.path == stub.path && $0.method == stub.method }) {
            stubs.remove(at: index)
        }
    }
    
    func requestHandler(request: HttpRequest) -> HttpResponse {
        guard let mocktail = stubs.flatMap({ stub -> Mocktail? in
            for (key, value) in stub.conditions {
                guard variables[key] == value else {
                    return nil
                }
            }

            return stub.canSatisfy(request: request) ? stub : nil
        }).first else {
            return .raw(501, "Not implemented", nil, nil)
        }
        
        defer {
            mocktail.variables.forEach { (key, value) in
                variables[key] = value
            }
        }
        
        return mocktail.response()
    }
}
