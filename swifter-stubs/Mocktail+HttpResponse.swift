//  Copyright © 2017 Nick Cross. All rights reserved.

import Foundation
import SwiftMocktail
import Swifter

extension Mocktail {
    
    func response(withDefaultDelay defaultDelay: Int = 1) -> HttpResponse {
        return HttpResponse.raw(responseStatusCode, "Stubbed", headers()) { responseBodyWriter in
            guard let data = self.data else { return }

            let delay: Int = self.delay ?? defaultDelay
            
            sleep(UInt32(delay))
            
            try? responseBodyWriter.write(data)
        }
    }

    //MARK: - Private

    private func headers() -> [String : String] {
        return responseHeaders.filter { header, _ -> Bool in
            return !shouldIgnore(header: header)
        }
    }
    
    private var data: Data? {
        return responseBody.data(using: .utf8)
    }
    
}
