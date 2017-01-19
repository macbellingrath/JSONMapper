//
//  JSON.swift
//  JSON
//
//  Created by Juan Alvarez on 2/11/15.
//  Copyright (c) 2015 Alvarez Productions. All rights reserved.
//

import Foundation

public typealias JSONDict = NSDictionary
public typealias JSONArray = [JSONDict]

public protocol JSONMappable {
    init(mapper: JSONMapper)
}

public struct JSONDateFormatter {
    fileprivate static var formatters: [String: DateFormatter] = [:]
    
    public static func registerDateFormatter(_ formatter: DateFormatter, withKey key: String) {
        formatters[key] = formatter
    }
    
    public static func dateFormatterWith(_ key: String) -> DateFormatter? {
        return formatters[key]
    }
}

public final class JSONAdapter <N: JSONMappable> {
    
    fileprivate init() {}
    
    public class func objectFromJSONDictionary(_ dict: JSONDict) -> N {
        let mapper = JSONMapper(dictionary: dict)
        let object = N(mapper: mapper)
        
        return object
    }
    
    public class func objectsFromJSONArray(_ array: JSONArray) -> [N] {
        let results = array.map({ (json: JSONDict) -> N in
            return self.objectFromJSONDictionary(json)
        })
        
        return results
    }
    
    public class func objectsFromJSONFile(_ url: URL) -> [N]? {
        if let data = try? Data(contentsOf: url) {
            return objectsFromJSONData(data)
        }
        
        return nil
    }
    
    public class func objectsFromJSONData(_ data: Data) -> [N]? {
        if let json: AnyObject = try! JSONSerialization.jsonObject(with: data, options: []) as AnyObject? {
            if let dict = json as? JSONDict {
                return [objectFromJSONDictionary(dict)]
            }
            
            if let array = json as? JSONArray {
                return objectsFromJSONArray(array)
            }
        }
        
        return nil
    }
    
    public class func objectsFrom(_ array: [AnyObject]) -> [N]? {
        if let array = array as? JSONArray {
            return objectsFromJSONArray(array)
        }
        
        return nil
    }
    
    public class func objectsValueFrom(_ array: [AnyObject]) -> [N] {
        if let array = objectsFrom(array) {
            return array
        }
        
        return []
    }
    
    public class func objectFrom(_ object: AnyObject) -> N? {
        if let dict = object as? JSONDict {
            return objectFromJSONDictionary(dict)
        }
        
        return nil
    }
}

public final class JSONMapper {
    
    public let rawJSONDictionary: JSONDict
    
    public init(dictionary: JSONDict) {
        rawJSONDictionary = dictionary
    }
    
    public subscript(keyPath: String) -> AnyObject? {
        return rawJSONDictionary.value(forKeyPath: keyPath) as AnyObject?
    }
}

extension JSONMapper: ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = AnyObject
    
    public convenience init(dictionaryLiteral elements: (Key, Value)...) {
        var dictionary = [String: AnyObject]()
        
        for (key_, value) in elements {
            dictionary[key_] = value
        }
        
        self.init(dictionary: dictionary as JSONDict)
    }
}

// MARK: String

extension JSONMapper {
    
    public func stringFor(_ keyPath: String) -> String? {
        return rawJSONDictionary.value(forKeyPath: keyPath) as? String
    }
    
    public func stringValueFor(_ keyPath: String) -> String {
        return stringFor(keyPath) ?? ""
    }
    
    public func stringValueFor(_ keyPath: String, defaultValue: String) -> String {
        return stringFor(keyPath) ?? defaultValue
    }
}

// MARK: Int

extension JSONMapper {
    
    public func intFor(_ keyPath: String) -> Int? {
        return rawJSONDictionary.value(forKeyPath: keyPath) as? Int
    }
    
    public func intValueFor(_ keyPath: String) -> Int {
        return intFor(keyPath) ?? 0
    }
    
    public func intValueFor(_ keyPath: String, defaultValue: Int) -> Int {
        return intFor(keyPath) ?? defaultValue
    }
}

// MARK: Bool

extension JSONMapper {
    
    public func boolFor(_ keyPath: String) -> Bool? {
        if let value = rawJSONDictionary.value(forKeyPath: keyPath) as? Bool {
            return value
        }
        
        if let value = rawJSONDictionary.value(forKeyPath: keyPath) as? String {
            switch value.lowercased() {
            case "true", "yes", "1":
                return true
            case "false", "no", "0":
                return false
            default:
                return nil
            }
        }
        
        return nil
    }
    
    public func boolValueFor(_ keyPath: String) -> Bool {
        return boolFor(keyPath) ?? false
    }
    
    public func boolValueFor(_ keyPath: String, defaultValue: Bool) -> Bool {
        return boolFor(keyPath) ?? defaultValue
    }
}

// MARK: Double

extension JSONMapper {
    
    public func doubleFor(_ keyPath: String) -> Double? {
        return rawJSONDictionary.value(forKeyPath: keyPath) as? Double
    }
    
    public func doubleValueFor(_ keyPath: String) -> Double {
        return doubleFor(keyPath) ?? 0.0
    }
    
    public func doubleValueFor(_ keyPath: String, defaultValue: Double) -> Double {
        return doubleFor(keyPath) ?? defaultValue
    }
}

// MARK: Float

extension JSONMapper {
    
    public func floatFor(_ keyPath: String) -> Float? {
        return rawJSONDictionary.value(forKeyPath: keyPath) as? Float
    }
    
    public func floatValueFor(_ keyPath: String) -> Float {
        return floatFor(keyPath) ?? 0.0
    }
    
    public func floatValueFor(_ keyPath: String, defaultValue: Float) -> Float {
        return floatFor(keyPath) ?? defaultValue
    }
}

// MARK: Array

extension JSONMapper {
    
    public func arrayFor<T>(_ keyPath: String) -> [T]? {
        return rawJSONDictionary.value(forKeyPath: keyPath) as? [T]
    }
    
    public func arrayValueFor<T>(_ keyPath: String) -> [T] {
        return arrayFor(keyPath) ?? [T]()
    }
    
    public func arrayValueFor<T>(_ keyPath: String, defaultValue: [T]) -> [T] {
        return arrayFor(keyPath) ?? defaultValue
    }
}

// MARK: Set

extension JSONMapper {
    
    public func setFor<T>(_ keyPath: String) -> Set<T>? {
        if let array = rawJSONDictionary.value(forKeyPath: keyPath) as? [T] {
            return Set<T>(array)
        }
        
        return nil
    }
    
    public func setValueFor<T>(_ keyPath: String) -> Set<T> {
        return setFor(keyPath) ?? Set<T>()
    }
    
    public func setValueFor<T>(_ keyPath: String, defaultValue: Set<T>) -> Set<T> {
        return setFor(keyPath) ?? defaultValue
    }
}

// MARK: Dictionary

extension JSONMapper {
    
    public func dictionaryFor(_ keyPath: String) -> JSONDict? {
        return rawJSONDictionary.value(forKeyPath: keyPath) as? JSONDict
    }
    
    public func dictionaryValueFor(_ keyPath: String) -> JSONDict {
        return dictionaryFor(keyPath) ?? JSONDict()
    }
    
    public func dictionaryValueFor(_ keyPath: String, defaultValue: JSONDict) -> JSONDict {
        return dictionaryFor(keyPath) ?? defaultValue
    }
}

// MARK: NSDate

extension JSONMapper {
    
    public typealias DateTransformerFromInt = (_ value: Int) -> Date?
    public typealias DateTransformerFromString = (_ value: String) -> Date?
    
    public func dateFromIntFor(_ keyPath: String, transform: DateTransformerFromInt) -> Date? {
        if let value = intFor(keyPath) {
            return transform(value)
        }
        
        return nil
    }
    
    public func dateFromStringFor(_ keyPath: String, transform: DateTransformerFromString) -> Date? {
        if let value = stringFor(keyPath) {
            return transform(value)
        }
        
        return nil
    }
    
    public func dateFromStringFor(_ keyPath: String, withFormatterKey formatterKey: String) -> Date? {
        if let value = stringFor(keyPath), let formatter = JSONDateFormatter.dateFormatterWith(formatterKey) {
            return formatter.date(from: value)
        }
        
        return nil
    }
}

// MARK: URL

extension JSONMapper {
    
    public func urlFrom(_ keyPath: String) -> URL? {
        if let value = stringFor(keyPath), !value.isEmpty {
            return URL(string: value)
        }
        
        return nil
    }
    
    public func urlValueFrom(_ keyPath: String, defaultValue: URL) -> URL {
        return urlFrom(keyPath) ?? defaultValue
    }
}

// MARK: Object: JSONMappable

extension JSONMapper {
    
    public func objectFor<T: JSONMappable>(_ keyPath: String) -> T? {
        if let dict = dictionaryFor(keyPath) {
            let mapper = JSONMapper(dictionary: dict)
            let object = T(mapper: mapper)
            
            return object
        }
        
        return nil
    }
    
    public func objectValueFor<T: JSONMappable>(_ keyPath: String) -> T {
        let dict = dictionaryValueFor(keyPath)
        
        let mapper = JSONMapper(dictionary: dict)
        let object = T(mapper: mapper)
        
        return object
    }
}

// MARK: Objects Array: JSONMappable

extension JSONMapper {
    
    fileprivate func _objectsArrayFrom<T: JSONMappable>(_ array: JSONArray) -> [T] {
        let results = array.map { (dict: JSONDict) -> T in
            let mapper = JSONMapper(dictionary: dict)
            let object = T(mapper: mapper)
            
            return object
        }
        
        return results
    }
    
    public func objectArrayFor<T: JSONMappable>(_ keyPath: String) -> [T]? {
        if let arrayValues = rawJSONDictionary.value(forKeyPath: keyPath) as? JSONArray {
            return _objectsArrayFrom(arrayValues)
        }
        
        return nil
    }
    
    public func objectArrayValueFor<T: JSONMappable>(_ keyPath: String) -> [T] {
        let arrayValues = rawJSONDictionary.value(forKeyPath: keyPath) as? JSONArray ?? JSONArray()
        
        return _objectsArrayFrom(arrayValues)
    }
    
    public func objectArrayValueFor<T: JSONMappable>(_ keyPath: String, defaultValue: [T]) -> [T] {
        return objectArrayFor(keyPath) ?? defaultValue
    }
}

// MARK: Objects Set: JSONMappable

extension JSONMapper {
    
    public func objectSetFor<T: JSONMappable>(_ keyPath: String) -> Set<T>? {
        if let values: [T] = objectArrayFor(keyPath) {
            return Set<T>(values)
        }
        
        return nil
    }
    
    public func objectSetValueFor<T: JSONMappable>(_ keyPath: String) -> Set<T> {
        return objectSetFor(keyPath) ?? Set<T>()
    }
    
    public func objectSetValueFor<T: JSONMappable>(_ keyPath: String, defaultValue: Set<T>) -> Set<T> {
        return objectSetFor(keyPath) ?? defaultValue
    }
}

// MARK: Transforms

extension JSONMapper {
    
    public func transform<T, U>(_ keyPath: String, block: (_ value: T) -> U?) -> U? {
        if let aValue = rawJSONDictionary.value(forKeyPath: keyPath) as? T {
            return block(aValue)
        }
        
        return nil
    }
    
    public func transformValue<T, U>(_ keyPath: String, defaultValue: U, block: (_ value: T) -> U) -> U {
        if let aValue = rawJSONDictionary.value(forKeyPath: keyPath) as? T {
            return block(aValue)
        }
        
        return defaultValue
    }
}

// MARK: Mapping

extension JSONMapper {
    
    public func mapArrayFor<T, U>(_ keyPath: String, block: (_ value: T) -> U) -> [U]? {
        if let array = rawJSONDictionary.value(forKeyPath: keyPath) as? [T] {
            let values = array.map(block)
            
            return values
        }
        
        return nil
    }
    
    public func mapArrayValueFor<T, U>(_ keyPath: String, block: (_ value: T) -> U) -> [U] {
        return mapArrayFor(keyPath, block: block) ?? [U]()
    }
    
    public func flatMapArrayFor<T, U>(_ keyPath: String, block: (_ value: T) -> U?) -> [U]? {
        if let array = rawJSONDictionary.value(forKeyPath: keyPath) as? [T] {
            var newValues = [U]()
            
            for item in array {
                if let value = block(item) {
                    newValues.append(value)
                }
            }
            
            return newValues
        }
        
        return nil
    }
    
    public func flatMapArrayValueFor<T, U>(_ keyPath: String, block: (_ value: T) -> U?) -> [U] {
        return flatMapArrayFor(keyPath, block: block) ?? [U]()
    }
}
