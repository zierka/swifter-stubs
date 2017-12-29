//  Copyright © 2017 Nick Cross. All rights reserved.

import Foundation
import SwiftMocktail
import Swifter

extension Mocktail {
    
    func response(withDefaultDelay defaultDelay: Double = 0.5) -> HttpResponse {
        return HttpResponse.raw(responseStatusCode, "Stubbed", headers()) { responseBodyWriter in
            guard let data = self.data else { return }

            let delay: Double = self.delay ?? defaultDelay
            
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + delay) {
                try? responseBodyWriter.write(data)
            }
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
