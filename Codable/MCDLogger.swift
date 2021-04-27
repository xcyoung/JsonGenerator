//
//  MCDLogger.swift
//  MCDLogger
//
//  Created by mconintet on 5/18/16.
//  Copyright © 2016 mconintet. All rights reserved.
//
import Foundation

public enum LogLevel: Int, CaseIterable {
    case None = 0
    case Info = 1
    case Alert = 2
    case Error = 3
    case Debug = 4
}

public struct StdOutputStream: TextOutputStream {
    public mutating func write(_ string: String) {
        fputs(string, __stdoutp)
    }
}

public struct StringOutputStream: TextOutputStream {
    public var out = ""

    public mutating func write(_ string: String) {
        out += string
    }

    public mutating func reset() {
        out = ""
    }
}

//var defaultDateFormatterToken = {0}()
let _defaultDateFormatter = DateFormatter()

public class MCDLogger {
//    static var level: LogLevel = .All

    static var outStream = StdOutputStream()

    static var includeCaller = true

    static var defaultDateFormatter: DateFormatter = {
        let _defaultDateFormatter = DateFormatter.init()
        _defaultDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return _defaultDateFormatter
    }()

    static var dateFormatter = defaultDateFormatter

    static func _log(level: LogLevel, _ items: [Any], separator: String = " ", terminator: String = "\n",
        _ file: String = #file, _ line: Int = #line, _ function: String = #function)
    {
        guard LogLevel.allCases.contains(level) else {
            return
        }

        if level == .Debug && !_isDebugAssertConfiguration() {
            return
        }

        var str = ""
        switch level {
        case LogLevel.Info:
            str = "[INFO]"
        case LogLevel.Alert:
            str = "[Alert]"
        case LogLevel.Error:
            str = "[Error]"
        case LogLevel.Debug:
            str = "[Debug]"
        default:
            break
        }

        var strStream = StringOutputStream()
        str += separator + dateFormatter.string(from: Date()) + separator

        if includeCaller {
            str += file + ":\(line):" + function + separator
        }

        var i = 1
        let len = items.count
        for item in items {
            debugPrint(item, separator: "", terminator: "", to: &strStream)
            str += strStream.out
            strStream.reset()
            if i == len {
                str += terminator
                break
            }
            str += separator
            i += 1
        }
        outStream.write(str)
    }

    static func log(level: LogLevel, _ items: Any ..., separator: String = " ", terminator: String = "\n",
        _ file: String = #file, _ line: Int = #line, _ function: String = #function)
    {
        _log(level: level, items, separator: separator, terminator: terminator, file, line, function)
    }
}

#if NOCONVENIENT
#else
    public func INFO(items: Any ..., separator: String = " ", terminator: String = "\n",
        _ file: String = #file, _ line: Int = #line, _ function: String = #function)
    {
        MCDLogger._log(level: .Info, items, separator: separator, terminator: terminator, file, line, function)
    }

    public func ALERT(items: Any ..., separator: String = " ", terminator: String = "\n",
        _ file: String = #file, _ line: Int = #line, _ function: String = #function)
    {
        MCDLogger._log(level: .Alert, items, separator: separator, terminator: terminator, file, line, function)
    }

    public func DEBUG(items: Any ..., separator: String = " ", terminator: String = "\n",
        _ file: String = #file, _ line: Int = #line, _ function: String = #function)
    {
        MCDLogger._log(level: .Debug, items, separator: separator, terminator: terminator, file, line, function)
    }

    public func ERROR(items: Any ..., separator: String = " ", terminator: String = "\n",
        _ file: String = #file, _ line: Int = #line, _ function: String = #function)
    {
        MCDLogger._log(level: .Error, items, separator: separator, terminator: terminator, file, line, function)
    }
#endif
