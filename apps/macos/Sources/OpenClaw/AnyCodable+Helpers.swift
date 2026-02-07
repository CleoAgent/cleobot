import CleoBotKit
import CleoBotProtocol
import Foundation

// Prefer the CleoBotKit wrapper to keep gateway request payloads consistent.
typealias AnyCodable = CleoBotKit.AnyCodable
typealias InstanceIdentity = CleoBotKit.InstanceIdentity

extension AnyCodable {
    var stringValue: String? { self.value as? String }
    var boolValue: Bool? { self.value as? Bool }
    var intValue: Int? { self.value as? Int }
    var doubleValue: Double? { self.value as? Double }
    var dictionaryValue: [String: AnyCodable]? { self.value as? [String: AnyCodable] }
    var arrayValue: [AnyCodable]? { self.value as? [AnyCodable] }

    var foundationValue: Any {
        switch self.value {
        case let dict as [String: AnyCodable]:
            dict.mapValues { $0.foundationValue }
        case let array as [AnyCodable]:
            array.map(\.foundationValue)
        default:
            self.value
        }
    }
}

extension CleoBotProtocol.AnyCodable {
    var stringValue: String? { self.value as? String }
    var boolValue: Bool? { self.value as? Bool }
    var intValue: Int? { self.value as? Int }
    var doubleValue: Double? { self.value as? Double }
    var dictionaryValue: [String: CleoBotProtocol.AnyCodable]? { self.value as? [String: CleoBotProtocol.AnyCodable] }
    var arrayValue: [CleoBotProtocol.AnyCodable]? { self.value as? [CleoBotProtocol.AnyCodable] }

    var foundationValue: Any {
        switch self.value {
        case let dict as [String: CleoBotProtocol.AnyCodable]:
            dict.mapValues { $0.foundationValue }
        case let array as [CleoBotProtocol.AnyCodable]:
            array.map(\.foundationValue)
        default:
            self.value
        }
    }
}
