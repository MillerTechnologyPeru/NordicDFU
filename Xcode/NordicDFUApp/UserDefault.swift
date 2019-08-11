//
//  File.swift
//  
//
//  Created by Guillermo Muntaner Perelló on 16/06/2019.
//

import Foundation
import Combine

/// A type safe property wrapper to set and get values from UserDefaults with support for defaults values.
///
/// Usage:
/// ```
/// @UserDefault("has_seen_app_introduction", defaultValue: false)
/// static var hasSeenAppIntroduction: Bool
/// ```
///
/// [Apple documentation on UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults)
@available(iOS 13, *)
@propertyWrapper
public final class UserDefault <Value: PropertyListValue> {
    
    public let key: String
    public let defaultValue: Value
    public var userDefaults: UserDefaults
    public let willChange = PassthroughSubject<Value, Never>()
    
    public init(_ key: String, defaultValue: Value, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }
    
    public var wrappedValue: Value {
        get { return userDefaults.object(forKey: key) as? Value ?? defaultValue }
        set {
            userDefaults.set(newValue, forKey: key)
            willChange.send(newValue)
        }
    }
}

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13, *)
extension UserDefault: BindableObject { }

@available(iOS 13, *)
extension UserDefault: BindingConvertible {
    
    public var binding: Binding<Value> {
        return Binding<Value>(
            getValue: { [unowned self] in self.wrappedValue },
            setValue: { [unowned self] in self.wrappedValue = $0 }
        )
    }
}
#endif

/// A type than can be stored in `UserDefaults`.
///
/// - From UserDefaults;
/// The value parameter can be only property list objects: NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary.
/// For NSArray and NSDictionary objects, their contents must be property list objects. For more information, see What is a
/// Property List? in Property List Programming Guide.
public protocol PropertyListValue {}

extension Data: PropertyListValue {}
extension NSData: PropertyListValue {}

extension String: PropertyListValue {}
extension NSString: PropertyListValue {}

extension Date: PropertyListValue {}
extension NSDate: PropertyListValue {}

extension NSNumber: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Int8: PropertyListValue {}
extension Int16: PropertyListValue {}
extension Int32: PropertyListValue {}
extension Int64: PropertyListValue {}
extension UInt: PropertyListValue {}
extension UInt8: PropertyListValue {}
extension UInt16: PropertyListValue {}
extension UInt32: PropertyListValue {}
extension UInt64: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}
#if os(macOS)
extension Float80: PropertyListValue {}
#endif

extension Array: PropertyListValue where Element: PropertyListValue {}

extension Dictionary: PropertyListValue where Key == String, Value: PropertyListValue {}
