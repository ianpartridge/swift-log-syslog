import CSyslog
import Logging

/// A `LogHandler` which logs to `syslog(3)`.
public struct SyslogLogHandler: LogHandler {
    private let lock = Lock()

    /// Create a `SyslogLogHandler`.
    public init(label: String) {
        self.label = label
        label.withCString {
            openlog($0, LOG_CONS | LOG_PID | LOG_NDELAY, LOG_LOCAL0)
        }
    }

    public let label: String

    private var _logLevel: Logger.Level = .info
    public var logLevel: Logger.Level {
        get {
            return self.lock.withLock { self._logLevel }
        }
        set {
            self.lock.withLock {
                self._logLevel = newValue
            }
        }
    }

    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    file: String, function: String, line: UInt) {
        let prettyMetadata = metadata?.isEmpty ?? true
            ? self.prettyMetadata
            : self.prettify(self.metadata.merging(metadata!, uniquingKeysWith: { _, new in new }))

        let message = "\(prettyMetadata.map { " \($0)" } ?? "") \(message)"
        message.withCString {
            syslog_helper(level.asSyslogPriority(), $0)
        }
    }

    private var prettyMetadata: String?
    private var _metadata = Logger.Metadata() {
        didSet {
            self.prettyMetadata = self.prettify(self._metadata)
        }
    }
    public var metadata: Logger.Metadata {
        get {
            return self.lock.withLock { self._metadata }
        }
        set {
            self.lock.withLock { self._metadata = newValue }
        }
    }

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.lock.withLock { self._metadata[metadataKey] }
        }
        set {
            self.lock.withLock {
                self._metadata[metadataKey] = newValue
            }
        }
    }

    private func prettify(_ metadata: Logger.Metadata) -> String? {
        return !metadata.isEmpty ? metadata.map { "\($0)=\($1)" }.joined(separator: " ") : nil
    }
}

extension Logger.Level {
    func asSyslogPriority() -> Int32 {
        switch self {
        case .trace:
            // syslog does not have "trace", so use debug for this
            return LOG_DEBUG
        case .debug:
            return LOG_DEBUG
        case .info:
            return LOG_INFO
        case .notice:
            return LOG_NOTICE
        case .warning:
            return LOG_WARNING
        case .error:
            return LOG_ERR
        case .critical:
            return LOG_CRIT
        }
    }
}
