//  Copyright © 2017 Nick Cross. All rights reserved.


import Foundation
import XCTest
@testable import SwifterStubs
import SwiftMocktail
@testable import Swifter

class StubRegisterTests: XCTestCase {
    
    private var requestAuthority: MockRequestAuthority!
    private var register: StubRegister!
    
    override func setUp() {
        super.setUp()
        requestAuthority = MockRequestAuthority()
        register = StubRegister(requestAuthority: requestAuthority)
    }

    func testReturnNotImplementedResponse() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "test", ofType: "tail")!
        let stub = try! Mocktail(path: path)
        
        requestAuthority.allowRequestResult = false
        register.register(stub: stub)

        let response: HttpResponse = register.requestHandler(request: HttpRequest())
        
        XCTAssertEqual(response.statusCode(), 501)
        
        XCTAssertTrue(requestAuthority.didCallAllowRequest)
        XCTAssertFalse(requestAuthority.didCallUpdate)
    }
    
    func testReturnStubbedResponse() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "test", ofType: "tail")!
        let stub = try! Mocktail(path: path)
        
        register.register(stub: stub)
        
        let response: HttpResponse = register.requestHandler(request: HttpRequest())
        XCTAssertEqual(response.statusCode(), 200)
        
        XCTAssertTrue(requestAuthority.didCallAllowRequest)
        XCTAssertFalse(requestAuthority.didCallUpdate)
    }
    
    func testReturnStubbedResponseSetServerState() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "stubs_set_headers_test", ofType: "tail")!
        let stub = try! Mocktail(path: path)
        
        register.register(stub: stub)
        
        let response: HttpResponse = register.requestHandler(request: HttpRequest())
        XCTAssertEqual(response.statusCode(), 200)
        
        XCTAssertTrue(requestAuthority.didCallAllowRequest)
        XCTAssertTrue(requestAuthority.didCallUpdate)
        
        XCTAssertEqual(requestAuthority.setVariables, ["variable1": "value1", "variable3": "value3"])
    }
    
    func testReturnNotImplementedResponseAfterStubRemoval() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "test", ofType: "tail")!
        let stub = try! Mocktail(path: path)
        
        register.register(stub: stub)
        register.remove(stub: stub)
        
        let response: HttpResponse = register.requestHandler(request: HttpRequest())
        XCTAssertEqual(response.statusCode(), 501)
    }
}

class MockRequestAuthority: RequestAuthority {
    var didCallUpdate: Bool = false
    var didCallAllowRequest: Bool = false
    
    var allowRequestResult: Bool = true
    
    var setVariables: [String: String] = [:]
    
    override func update(variable: String, withValue value: String) {
        didCallUpdate = true
        setVariables[variable] = value
    }
    
    override func allowRequest(forMethod method: String, path: String, withParams params: [String : String], withStub stub: Mocktail) -> Bool {
        didCallAllowRequest = true
        return allowRequestResult
    }
}
