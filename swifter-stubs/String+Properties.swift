//  Copyright © 2017 Nick Cross. All rights reserved.

import Foundation

extension String {
    func asPropertyDictionary() -> [String: String] {
        let properties: [(String, String)] = split(",").flatMap { keyValue in
            guard keyValue.count > 0 else { return nil }
            
            let splitKeyValue = keyValue.split("=")
            
            guard splitKeyValue.count == 2 else {
                return (keyValue,"")
            }
            
            return (splitKeyValue[0], splitKeyValue[1])
        }
        
        return Dictionary(properties) { key, value in
            return key
        }
    }
}
