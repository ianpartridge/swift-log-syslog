import CSyslog
import Logging

/// A `LogHandler` which logs to `syslog(3)`.
public struct SyslogLogHandler: LogHandler {
    public enum Facility: Int32 {
        case auth
        case authpriv
        case cron
        case daemon
        case ftp
        case kern
        case local0
        case local1
        case local2
        case local3
        case local4
        case local5
        case local6
        case local7
        case lpr
        case mail
        case news
        case syslog
        case user
        case uucp

        public var rawValue: Int32 {
            switch self {
            case .auth: return LOG_AUTH
            case .authpriv: return LOG_AUTHPRIV
            case .cron: return LOG_CRON
            case .daemon: return LOG_DAEMON
            case .ftp: return LOG_FTP
            case .kern: return LOG_KERN
            case .local0: return LOG_LOCAL0
            case .local1: return LOG_LOCAL1
            case .local2: return LOG_LOCAL2
            case .local3: return LOG_LOCAL3
            case .local4: return LOG_LOCAL4
            case .local5: return LOG_LOCAL5
            case .local6: return LOG_LOCAL6
            case .local7: return LOG_LOCAL7
            case .lpr: return LOG_LPR
            case .mail: return LOG_MAIL
            case .news: return LOG_NEWS
            case .syslog: return LOG_SYSLOG
            case .user: return LOG_USER
            case .uucp: return LOG_UUCP
            }
        }
    }
    
    public struct Option: OptionSet {
        public let rawValue: Int32
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        public static let cons = Option(rawValue: LOG_CONS)
        public static let ndelay = Option(rawValue: LOG_NDELAY)
        public static let nowait = Option(rawValue: LOG_NOWAIT)
        public static let odelay = Option(rawValue: LOG_ODELAY)
        public static let perror = Option(rawValue: LOG_PERROR)
        public static let pid = Option(rawValue: LOG_PID)
    }
    
    /// Create a `SyslogLogHandler`.
    public init(label: String, ident: String? = nil, facility: Facility = .user, option: Option = .odelay) {
        self.label = label
        openlog(ident, option.rawValue, facility.rawValue);
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
