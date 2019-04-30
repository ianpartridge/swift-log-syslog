import Logging
import LoggingSyslog
import XCTest

final class SyslogLogHandlerTests: XCTestCase {
    func testHelloWorld() {
        LoggingSystem.bootstrap(SyslogLogHandler.init)

        let logger = Logger(label: "SwiftLogSyslogTest")
        logger.info("Hello World!")
    }
}
