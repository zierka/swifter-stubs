//  Copyright © 2017 Nick Cross. All rights reserved.

import Foundation
import SwiftMocktail

extension Mocktail {

    func canSatisfyRequest(forMethod requestMethod: String, path requestPath: String, withParams requestParams: [String: String]) -> Bool {
        guard SwiftMocktail.Method.other(requestMethod) == method else {
            return false
        }
        
        guard let expression = try? NSRegularExpression(pattern:"^\(partialPath)$", options: .caseInsensitive) else {
            fatalError("Failed to create regular expression from partial path: \(partialPath)")
        }
        
        guard expression.firstMatch(in: requestPath, options: [], range: NSMakeRange(0,requestPath.count)) != nil else {
            return false
        }
        
        for case let param in params.keys where requestParams[param] != params[param] {
            return false
        }
        
        return true
    }

    //MARK: - Private
    
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
