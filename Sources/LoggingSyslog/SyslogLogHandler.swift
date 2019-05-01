import CSyslog
import Logging

/// A `LogHandler` which logs to `syslog(3)`.
public struct SyslogLogHandler: LogHandler {

    /// Create a `SyslogLogHandler`.
    public init(label: String) {
        self.label = label
    }

    public let label: String

    public var logLevel: Logger.Level = .info

    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    file: String, function: String, line: UInt) {
        let prettyMetadata = metadata?.isEmpty ?? true
            ? self.prettyMetadata
            : self.prettify(self.metadata.merging(metadata!, uniquingKeysWith: { _, new in new }))

        let message = "\(self.label): \(prettyMetadata.map { " \($0)" } ?? "") \(message)"
        message.withCString {
            syslog_helper(level.asSyslogPriority(), $0)
        }
    }

    private var prettyMetadata: String?
    public var metadata = Logger.Metadata() {
        didSet {
            self.prettyMetadata = self.prettify(self.metadata)
        }
    }

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
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
