//  Copyright © 2017 Nick Cross. All rights reserved.


import Foundation
import XCTest
@testable import SwifterStubs
@testable import Swifter
import SwiftMocktail

class RequestAuthorityTests: XCTestCase {

    private var requestAuthority: RequestAuthority!
    
    override func setUp() {
        super.setUp()
        requestAuthority = RequestAuthority()
    }
    
    func testDisallowRequestNotSatisfyingConditions() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "stubs_headers_test", ofType: "tail")!
        XCTAssertFalse(requestAuthority.allowRequest(forMethod: "GET", path: "test/path/expres", withParams: [:], withStub: try! Mocktail(path: path)))
    }
  
    func testDisallowRequestPartlySatisfyingConditions() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "stubs_headers_test", ofType: "tail")!
        
        requestAuthority.update(variable: "variable1", withValue: "value1")
        
        XCTAssertFalse(requestAuthority.allowRequest(forMethod: "GET", path: "test/path/expres", withParams: [:], withStub: try! Mocktail(path: path)))
    }

    func testAllowRequestSatisfyingConditions() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "stubs_headers_test", ofType: "tail")!
        
        requestAuthority.update(variable: "variable1", withValue: "value1")
        requestAuthority.update(variable: "variable3", withValue: "value3")
        
        XCTAssertTrue(requestAuthority.allowRequest(forMethod: "GET", path: "test/path/expres", withParams: [:], withStub: try! Mocktail(path: path)))
    }

    func testAllowSimpleRequest() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "test", ofType: "tail")!
        
        XCTAssertTrue(requestAuthority.allowRequest(forMethod: "GET", path: "test/path/expres", withParams: [:], withStub: try! Mocktail(path: path)))
    }
    
    func testDisallowSimpleRequestWithNonMatchingMethod() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "test", ofType: "tail")!
        
        XCTAssertFalse(requestAuthority.allowRequest(forMethod: "POST", path: "test/path/expres", withParams: [:], withStub: try! Mocktail(path: path)))
    }
    
    func testDisallowSimpleRequestWithNonMatchingPath() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "test", ofType: "tail")!
        
        XCTAssertFalse(requestAuthority.allowRequest(forMethod: "GET", path: "test/path/expres1", withParams: [:], withStub: try! Mocktail(path: path)))
    }
    
    func testAllowSimpleRequestWithNonRequiredParams() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "test", ofType: "tail")!
        
        XCTAssertTrue(requestAuthority.allowRequest(forMethod: "GET", path: "test/path/expres", withParams: ["asdf":"asdf"], withStub: try! Mocktail(path: path)))
    }
    
    func testDisallowSimpleRequestWithNonMatchingParams() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "query_test", ofType: "tail")!
        
        XCTAssertFalse(requestAuthority.allowRequest(forMethod: "GET", path: "test/path/expres", withParams: ["qwer":"qwer"], withStub: try! Mocktail(path: path)))
    }
    
    func testDisallowSimpleRequestWithMatchingParams() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "query_test", ofType: "tail")!
        
        XCTAssertTrue(requestAuthority.allowRequest(forMethod: "GET", path: "test/path/expres", withParams: ["asdf":"asdf"], withStub: try! Mocktail(path: path)))
    }
    
    func testAllowRequestWithRegexPath() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "regex_test", ofType: "tail")!
        
        XCTAssertTrue(requestAuthority.allowRequest(forMethod: "GET", path: "test/path/expres", withParams: [:], withStub: try! Mocktail(path: path)))
    }
    
    func testDisallowRequestWithRegexPathThatDoesNotMatch() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "regex_test", ofType: "tail")!
        
        XCTAssertFalse(requestAuthority.allowRequest(forMethod: "GET", path: "test1/path/expres", withParams: [:], withStub: try! Mocktail(path: path)))
    }
    
    func testAllowRequestWithRegexPathWithParams() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "query_regex_test", ofType: "tail")!
        
        XCTAssertTrue(requestAuthority.allowRequest(forMethod: "GET", path: "test/ad/expres", withParams: ["asdf":"asdf"], withStub: try! Mocktail(path: path)))
    }
    
    func testDisallowRequestWithRegexPathWithNonMatchingParams() {
        let path = Bundle(for: RequestAuthorityTests.self).path(forResource: "query_regex_test", ofType: "tail")!
        
        XCTAssertFalse(requestAuthority.allowRequest(forMethod: "GET", path: "test/ad/expres", withParams: ["qwer":"qwer"], withStub: try! Mocktail(path: path)))
    }
}
