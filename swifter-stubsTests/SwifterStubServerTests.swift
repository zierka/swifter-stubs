//  Copyright © 2017 Nick Cross. All rights reserved.

import XCTest
@testable import SwifterStubs
import SwifterStubServer
@testable import Swifter
import NetUtils

class SwifterStubServerTests: XCTestCase {
    
    private var stubRegister: StubRegister!
    private var stubServer: HttpStubServer!
    
    override func setUp() {
        super.setUp()
        stubRegister = StubRegister()
        StubRegister.sharedRegister = stubRegister
        stubServer = HttpServer.createStubServer()
    }

    func testStubServerCreation() {
        XCTAssertNotNil(stubServer)
        
        let request = HttpRequest()
        request.method = "get"
        request.path = "test/path/expres"
        let response = stubRegister.requestHandler(request: request)
        
        XCTAssertEqual(response.statusCode(), 501)
    }
    
    func testEnableStubGET() {
        let path = Bundle(for: SwifterStubServerTests.self).path(forResource: "test", ofType: "tail")
        try! stubServer.enableStub(forFile: path!)
        
        let request = HttpRequest()
        request.method = "get"
        request.path = "test/path/expres"
        let response = stubRegister.requestHandler(request: request)
        
        XCTAssertEqual(response.statusCode(), 200)
        XCTAssertEqual(response.headers()["Content-Type"], "application/json")
        
        let writer = BodyWriter()
        try! response.content().write?(writer)
        wait(for: [writer.didWriteData], timeout: 1.0)
        XCTAssertEqual(writer.responseString, "{\n\"asdf\" : \"adsfasd\"\n}\n")
    }
    
    func testEnableStubQueryString() {
        let path = Bundle(for: SwifterStubServerTests.self).path(forResource: "query_test", ofType: "tail")
        try! stubServer.enableStub(forFile: path!)
        
        let request = HttpRequest()
        request.method = "get"
        request.path = "test/path/expres"
        request.params = ["asdf":"asdf", "something":"wedontcareabout"]
        let response = stubRegister.requestHandler(request: request)
        
        XCTAssertEqual(response.statusCode(), 200)
        XCTAssertEqual(response.headers()["Content-Type"], "application/json")
        
        let writer = BodyWriter()
        try! response.content().write?(writer)
        wait(for: [writer.didWriteData], timeout: 1.0)
        XCTAssertEqual(writer.responseString, "{\n\"asdf\" : \"adsfasd\"\n}\n")
    }

    func testEnableStubRegex() {
        let path = Bundle(for: SwifterStubServerTests.self).path(forResource: "regex_test", ofType: "tail")
        try! stubServer.enableStub(forFile: path!)
        
        let request = HttpRequest()
        request.method = "get"
        request.path = "test/asdfasdfasfdafa/expres"
        let response = stubRegister.requestHandler(request: request)
        
        XCTAssertEqual(response.statusCode(), 200)
        XCTAssertEqual(response.headers()["Content-Type"], "application/json")
        
        let writer = BodyWriter()
        try! response.content().write?(writer)
        wait(for: [writer.didWriteData], timeout: 1.0)
        XCTAssertEqual(writer.responseString, "{\n\"asdf\" : \"adsfasd\"\n}\n")
    }

    func testEnableStubRegexQueryString() {
        let path = Bundle(for: SwifterStubServerTests.self).path(forResource: "query_regex_test", ofType: "tail")
        try! stubServer.enableStub(forFile: path!)
        
        let request = HttpRequest()
        request.method = "get"
        request.path = "test/adf/expres"
        request.params = ["asdf":"asdf"]
        let response = stubRegister.requestHandler(request: request)
        
        XCTAssertEqual(response.statusCode(), 200)
        XCTAssertEqual(response.headers()["Content-Type"], "application/json")
        
        let writer = BodyWriter()
        try! response.content().write?(writer)
        wait(for: [writer.didWriteData], timeout: 1.0)
        XCTAssertEqual(writer.responseString, "{\n\"asdf\" : \"adsfasd\"\n}\n")
    }
    
    func testEnableStubPOST() {
        let path = Bundle(for: SwifterStubServerTests.self).path(forResource: "post_test", ofType: "tail")
        try! stubServer.enableStub(forFile: path!)
        
        let request = HttpRequest()
        request.method = "post"
        request.path = "test/path/expres"
        let response = stubRegister.requestHandler(request: request)
        
        XCTAssertEqual(response.statusCode(), 201)
        XCTAssertEqual(response.headers()["Content-Type"], "application/json")
        
        let writer = BodyWriter()
        try! response.content().write?(writer)
        wait(for: [writer.didWriteData], timeout: 1.0)
        XCTAssertEqual(writer.responseString, "{\n\"asdf\" : \"adsfasd\"\n}\n")
    }
    
    func testEnableStubForMultipleMethods() {
        let getPath = Bundle(for: SwifterStubServerTests.self).path(forResource: "test", ofType: "tail")
        let postPath = Bundle(for: SwifterStubServerTests.self).path(forResource: "post_test", ofType: "tail")
        try! stubServer.enableStub(forFile: getPath!)
        try! stubServer.enableStub(forFile: postPath!)
        
        var request = HttpRequest()
        request.method = "get"
        request.path = "test/path/expres"
        var response = stubRegister.requestHandler(request: request)
        
        XCTAssertEqual(response.statusCode(), 200)
        
        request = HttpRequest()
        request.method = "post"
        request.path = "test/path/expres"
        response = stubRegister.requestHandler(request: request)
        XCTAssertEqual(response.statusCode(), 201)
    }
    
    func testEnableStubGETStrippingStubHeaders() {
        let path = Bundle(for: SwifterStubServerTests.self).path(forResource: "stubs_headers_test", ofType: "tail")
        try! stubServer.enableStub(forFile: path!)
        
        let request = HttpRequest()
        request.method = "get"
        request.path = "test/path/expres"
        let response = stubRegister.requestHandler(request: request)
        
        XCTAssertEqual(response.statusCode(), 200)
        XCTAssertEqual(response.headers()["Content-Type"], "application/json")
        XCTAssertNil(response.headers()["stub-only-if"])
        XCTAssertNil(response.headers()["stub-set"])
        
        let writer = BodyWriter()
        try! response.content().write?(writer)
        wait(for: [writer.didWriteData], timeout: 1.0)
        XCTAssertEqual(writer.responseString, "{\n\"asdf\" : \"adsfasd\"\n}\n")
    }
    
    func testDisableStub() {
        let path = Bundle(for: SwifterStubServerTests.self).path(forResource: "test", ofType: "tail")
        try! stubServer.enableStub(forFile: path!)
        
        try! stubServer.disableStub(forFile: path!)
        
        let request = HttpRequest()
        request.method = "get"
        request.path = "test/path/expres"
        let response = stubRegister.requestHandler(request: request)
        
        XCTAssertEqual(response.statusCode(), 501)
    }
    
    
    func testDisableStubForSingleMethod() {
        let getPath = Bundle(for: SwifterStubServerTests.self).path(forResource: "test", ofType: "tail")
        let postPath = Bundle(for: SwifterStubServerTests.self).path(forResource: "post_test", ofType: "tail")
        try! stubServer.enableStub(forFile: getPath!)
        try! stubServer.enableStub(forFile: postPath!)
        
        try! stubServer.disableStub(forFile: getPath!)
        
        var request = HttpRequest()
        request.method = "get"
        request.path = "test/path/expres"
        var response = stubRegister.requestHandler(request: request)
        
        XCTAssertEqual(response.statusCode(), 501)
        
        request = HttpRequest()
        request.method = "post"
        request.path = "test/path/expres"
        response = stubRegister.requestHandler(request: request)
        
        XCTAssertEqual(response.statusCode(), 201)
    }

    func testStartServer() {
        let addresss = HttpServer.availableInterfaces().filter({
            guard case IPAddress.v4(_) = $0.address else {
                return false
            }
            return $0.name.starts(with: "en")
        }).first?.address

        let startServer = { () throws -> Void in
            try self.stubServer.startStubServer(onPort: 4444, boundTo: addresss!)
        }
        
        XCTAssertNoThrow( try startServer() )
    }
    
    func testStopServer() {
        let stopServer = { () throws -> Void in
            try self.stubServer.stopStubServer()
        }
        
        XCTAssertNoThrow( try stopServer() )
    }
}

fileprivate class BodyWriter: HttpResponseBodyWriter {
    
    var data = Data()
    let didWriteData = XCTestExpectation(description: "data written")
    
    func write(_ file: String.File) throws {
        fatalError()
    }
    
    func write(_ data: [UInt8]) throws {
        fatalError()
    }
    
    func write(_ data: ArraySlice<UInt8>) throws {
        fatalError()
    }
    
    func write(_ data: NSData) throws {
        fatalError()
    }
    
    func write(_ data: Data) throws {
        self.data += data
        didWriteData.fulfill()
    }
    
    var responseString: String {
        return String(data: data, encoding: .utf8)!
    }
}
