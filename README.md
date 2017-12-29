# swifter-stubs
An extension to swifter http server that uses mocktail file format for defining stubbed endpoints

swifter-stubs is intended to be embedded into iOS apps to provide a simple way to replace apis that might be incomplete or inaccesible for various reasons.

## Getting Started

Installation is supported via [Carthage](https://github.com/Carthage/Carthage)

swifter-stubs can included in your app by adding the following line to your `Cartfile`

```
github "nicholascross/swifter-stubs"
```

Run `carthage update`

Add the following to your carthage copy frameworks phase

```bash
$(PROJECT_DIR)/Carthage/Build/iOS/SwiftMocktail.framework
$(PROJECT_DIR)/Carthage/Build/iOS/Swifter.framework
$(PROJECT_DIR)/Carthage/Build/iOS/SwifterStubs.framework
$(PROJECT_DIR)/Carthage/Build/iOS/NetUtils.framework
```

Link against the frameworks as you would with other carthage dependencies

### Dynamic Loading

Including a stub server in your production app is overly heavy so an interface has been extracted [swifter-stub-server](https://github.com/nicholascross/swifter-stub-server)

This allows you to include only the stub server protocol in your production app with no associated dependencies.

Instead of including swifter-stubs in `Cartfile` include the following

```
github "nicholascross/swifter-stub-server"
```

Include the following in your `Cartfile.private`

```
github "nicholascross/swifter-stubs"
```

Run `carthage update`

Add the following to your carthage copy frameworks phase

```bash
$(PROJECT_DIR)/Carthage/Build/iOS/SwifterStubServer.framework
```

Add a new `run script` build phase `Copy stub server frameworks`

*script*
```bash
if [ "${CONFIGURATION}" == "Debug" ]; then
carthage copy-frameworks
fi
```

*input files*
```bash
$(PROJECT_DIR)/Carthage/Build/iOS/SwiftMocktail.framework
$(PROJECT_DIR)/Carthage/Build/iOS/Swifter.framework
$(PROJECT_DIR)/Carthage/Build/iOS/SwifterStubs.framework
$(PROJECT_DIR)/Carthage/Build/iOS/NetUtils.framework
```
This will copy the additional frameworks only for debug builds.

Link **only** against `SwifterStubServer.framework` the other frameworks will be loaded dynamically.

Add the following at an appropriate place in your code

```swift
        //You might like to include this code only in debug builds
        #if Debug
        
        var server: HttpStubServer?
        
        //load all dependant frameworks
        initialiseStubServer { stubServer in
        
            //Load stub from file
            try? stubServer.enableStub(forFile: Bundle.main.path(forResource: "example", ofType: "tail")!)
            
            //Start stub server on given ip address and port
            try? stubServer.startStubServer(onPort: 4040, boundTo: .v4("192.168.0.100"))
            
            server = stubServer
        }
        
        #endif
```

## Dependencies

* [Swifter](https://github.com/httpswift/swifter) - Tiny http server engine written in Swift programming language.
* [swift-netutils](https://github.com/svdo/swift-netutils) - Swift library that simplifies getting information about your network interfaces and their properties, both for iOS and OS X.
* [SwiftMocktail](https://github.com/nicholascross/SwiftMocktail) - Mocktail file format in Swift
* [swifter-stub-server](https://github.com/nicholascross/swifter-stub-server) - Interface to swifter stub server - separated to allow dynamic loading

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/nicholascross/swifter-stubs/tags). 

## Authors

* **Nick Cross** - *Initial work* - [nicholascross](https://github.com/nicholascross)

See also the list of [contributors](https://github.com/nicholascross/swifter-stubs/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
