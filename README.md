# LoggingSyslog

This Swift package implements a logging backend that logs to [`syslog`](https://en.wikipedia.org/wiki/Syslog).

It is an implementation of a [`LogHandler`](https://github.com/apple/swift-log#on-the-implementation-of-a-logging-backend-a-loghandler) as defined by the Swift Server Working Group logging API.

## Usage

Add `https://github.com/ianpartridge/swift-log-syslog.git` as a dependency in your Package.swift.

Then, during your application startup, do:

```swift
import Logging
import LoggingSyslog

// Initialize the syslog logger
LoggingSystem.bootstrap(SyslogLogHandler.init)
```

Elsewhere in your application, when you need to log, do:

```swift
// Create a logger (or re-use one you already have)
let logger = Logger(label: "MyApp")

// Log!
logger.info("Hello World!")
```
