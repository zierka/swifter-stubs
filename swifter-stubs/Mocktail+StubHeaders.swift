//  Copyright © 2017 Nick Cross. All rights reserved.

import Foundation
import SwiftMocktail

enum StubHeaders: String {
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
    
    var delay: Double? {
        guard let delayString: String = responseHeaders[StubHeaders.delay.header] else {
            return nil
        }
        
        return Double(delayString)
    }
}
