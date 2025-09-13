//
//  Logger.swift
//  Event Tracker
//
//  Centralized logging system for the application
//

import Foundation
import os.log

final class Logger {
    
    enum LogLevel {
        case debug
        case info
        case warning
        case error
        
        var prefix: String {
            switch self {
            case .debug: return "🔍 DEBUG"
            case .info: return "ℹ️ INFO"
            case .warning: return "⚠️ WARNING"
            case .error: return "❌ ERROR"
            }
        }
    }
    
    enum Category {
        case auth
        case events
        case profile
        case session
        case categories
        case general
        
        var subsystem: String {
            return "com.eventtracker"
        }
        
        var category: String {
            switch self {
            case .auth: return "authentication"
            case .events: return "events"
            case .profile: return "profile"
            case .session: return "session"
            case .categories: return "categories"
            case .general: return "general"
            }
        }
    }
    
    private init() {}
    
    static func log(
        _ message: String,
        level: LogLevel = .info,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(level.prefix) [\(category.category.uppercased())] \(fileName):\(line) \(function) - \(message)"
        
        #if DEBUG
        print(logMessage)
        #endif
        
        let osLog = OSLog(subsystem: category.subsystem, category: category.category)
        os_log("%@", log: osLog, type: level.osLogType, logMessage)
    }
    
    // Convenience methods
    static func debug(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    static func info(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    static func warning(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    static func error(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }
}

private extension Logger.LogLevel {
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }
}