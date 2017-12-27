//  Copyright © 2017 Nick Cross. All rights reserved.


import Foundation
import Swifter
import SwiftMocktail
import SwifterStubServer
import NetUtils


enum HttpStubServerError: Error {
    case invalidStubFile
}

extension HttpServer: HttpStubServer {
    
    public static func createStubServer() -> HttpStubServer {
        return HttpServer()
    }
    
    public static func availableInterfaces() -> [(name: String, address: IPAddress)] {
        return Interface.allInterfaces().flatMap { interface in
            if let address = interface.address, interface.family == .ipv4 {
                return (name: interface.name, address: IPAddress.v4(address))
            }
            else if let address = interface.address, interface.family == .ipv6 {
                return (name: interface.name, address: IPAddress.v6(address)) 
            }
            else {
                return nil
            }
        }
    }
    
    public func startStubServer(onPort port: in_port_t, boundTo ipAddress: IPAddress) throws {
        var forceIPv4 = false
        
        if case .v4(let ipv4Address) = ipAddress {
            listenAddressIPv4 = ipv4Address
            forceIPv4 = true
        }
        else if case .v6(let ipv6Address) = ipAddress {
            listenAddressIPv6 = ipv6Address
        }
        
        notFoundHandler = StubRegister.sharedRegister.requestHandler
        
        try start(port, forceIPv4: forceIPv4, priority: .default)
    }
    
    public func stopStubServer() {
        stop()
    }
    
    public var ipAddress: String? {
        return listenAddressIPv4 ?? listenAddressIPv6
    }
    
    public func enableStub(forFile path: String) throws {
        let stubDefinition: Mocktail = try loadStub(fromFile: path)
        StubRegister.sharedRegister.register(stub: stubDefinition)
    }
    
    public func disableStub(forFile path: String) throws {
        let stubDefinition: Mocktail = try loadStub(fromFile: path)
        StubRegister.sharedRegister.remove(stub: stubDefinition)
    }

    // MARK: - Private
    
    private func loadStub(fromFile path: String) throws -> Mocktail {
        do {
            return try Mocktail(path: path)
        }
        catch let error where error is MocktailError {
            throw HttpStubServerError.invalidStubFile
        }
    }
    
}

