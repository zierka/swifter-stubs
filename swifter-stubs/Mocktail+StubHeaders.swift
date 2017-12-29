//  Copyright © 2017 Nick Cross. All rights reserved.

import Foundation
import SwiftMocktail

fileprivate enum StubHeaders: String {
    case onlyIf = "stub-only-if"
    case set = "stub-set"
    case delay = "stub-delay"
    
    var header: String {
        return rawValue
    }
}

extension Mocktail {
    var variables: [String: String] {
        guard let setHeader = responseHeaders[StubHeaders.set.header] else {
            return [:]
        }
        
        return setHeader.asPropertyDictionary()
    }
    
    var conditions: [String:String] {
        guard let onlyIfHeader = responseHeaders[StubHeaders.onlyIf.header] else {
            return [:]
        }
        
        return onlyIfHeader.asPropertyDictionary()
    }
    
    var delay: Int? {
        guard let delayString: String = responseHeaders[StubHeaders.delay.header] else {
            return nil
        }
        
        return Int(delayString)
    }
    
    func shouldIgnore(header: String) -> Bool {
        return StubHeaders(rawValue: header) != nil
    }
}
