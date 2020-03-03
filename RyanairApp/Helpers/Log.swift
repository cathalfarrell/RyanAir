//
//  Log.swift
//  Dugout
//
//  Created by Cathal Farrell on 08/03/2018.
//  Copyright © 2020 RyanaiAir. All rights reserved.
//

import Foundation

public class Log {
    private static var mLockObject: Log = Log()

    /// Verbose messages for detailed debugging
    public static var levelVerbose = 1
    /// Informational messages for overview
    public static var levelInfo = 2
    /// Warning message for unhappy lows
    public static var levelWarning = 3
    /// Errors that should not have occurred
    public static var levelError = 4
    /// Errors from which we may not be able to recover
    public static var levelCritical = 5

    #if DEBUG || TESTENV || DEVENV || UATENV || BETAENV //Development Or Pre-Production Testing
        private static var isDeveloperMode = true
        private static var level = levelVerbose
    #else
        private static var isDeveloperMode = false
        private static var level = levelCritical
    #endif

    /// Log a statement at debug level
    ///
    /// Always outputs in developer mode, never outputs in production mode
    /// - Parameter message: The debug message to output
    /// - Parameter function: The calling function - no need to pass this as it is defaulted correctly
    /// - Parameter file: The filename for the caller - no need to pass this as it is defaulted correctly
    /// - Parameter line: The line number for the caller - no need to pass this as it is defaulted correctly
    public class func d(_ message: String,
                        function: String = #function,
                        file: String = #file,
                        line: Int = #line)
    {
        if isDeveloperMode {
            Log.output(level: "[DEBUG]", message: message, function: function, file: file, line: line)
        }
    }

    /// Log a statement at VERBOSE level
    ///
    /// - Parameter message: The message to output
    /// - Parameter function: The calling function - no need to pass this as it is defaulted correctly
    /// - Parameter file: The filename for the caller - no need to pass this as it is defaulted correctly
    /// - Parameter line: The line number for the caller - no need to pass this as it is defaulted correctly
    public class func v(_ message: String,
                        function: String = #function,
                        file: String = #file,
                        line: Int = #line) {
        if self.level <= self.levelVerbose {
            Log.output(level: "❇️[FLAG]", message: message, function: function, file: file, line: line)
        }
    }

    /// Log a statement at INFO level
    ///
    /// - Parameter message: The message to output
    /// - Parameter function: The calling function - no need to pass this as it is defaulted correctly
    /// - Parameter file: The filename for the caller - no need to pass this as it is defaulted correctly
    /// - Parameter line: The line number for the caller - no need to pass this as it is defaulted correctly
    public class func i(_ message: String,
                        function: String = #function,
                        file: String = #file,
                        line: Int = #line) {
        if self.level <= self.levelInfo {
            Log.output(level: "ℹ️[INFO]", message: message, function: function, file: file, line: line)
        }
    }

    /// Log a statement at WARNING level
    ///
    /// - Parameter message: The message to output
    /// - Parameter function: The calling function - no need to pass this as it is defaulted correctly
    /// - Parameter file: The filename for the caller - no need to pass this as it is defaulted correctly
    /// - Parameter line: The line number for the caller - no need to pass this as it is defaulted correctly
    public class func w(_ message: String,
                        function: String = #function,
                        file: String = #file,
                        line: Int = #line) {
        if self.level <= self.levelWarning {
            Log.output(level: "⚠️[WARNING]", message: message, function: function, file: file, line: line)
        }
    }

    /// Log a statement at ERROR level
    ///
    /// - Parameter message: The message to output
    /// - Parameter function: The calling function - no need to pass this as it is defaulted correctly
    /// - Parameter file: The filename for the caller - no need to pass this as it is defaulted correctly
    /// - Parameter line: The line number for the caller - no need to pass this as it is defaulted correctly
    public class func e(_ message: String,
                        function: String = #function,
                        file: String = #file,
                        line: Int = #line) {
        if self.level <= self.levelError {
            Log.output(level: "🐞[ERROR]", message: message, function: function, file: file, line: line)
        }
    }

    /// Log a statement at CRITICAL level
    ///
    /// - Parameter message: The message to output
    /// - Parameter function: The calling function - no need to pass this as it is defaulted correctly
    /// - Parameter file: The filename for the caller - no need to pass this as it is defaulted correctly
    /// - Parameter line: The line number for the caller - no need to pass this as it is defaulted correctly
    public class func c(_ message: String,
                        function: String = #function,
                        file: String = #file,
                        line: Int = #line) {
        if self.level <= self.levelCritical {
            Log.output(level: "🔥[CRIT]", message: message, function: function, file: file, line: line)
        }
    }

    /// Set the debugging level - override the standard.
    ///
    /// - Parameter level: The level to use
    public class func setLevel(_ level: Int) {
        if true == isDeveloperMode {
            Log.level = level
        }
    }

    private class func output(
        level: String,
        message: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line) {
        #if TURN_OFF_DEBUG
        #else
            let fileURL = NSURL(string: file)
            var fileString = ""
            if let lastPathComponent = fileURL?.lastPathComponent {
                fileString = lastPathComponent
            }

            objc_sync_enter(mLockObject)
            print("\(level) \"\(message)\" (File: \(fileString), Function: \(function), Line: \(line))")
            objc_sync_exit(mLockObject)
        #endif
    }
}
