//
//  LossyDictionary.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 29.07.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation
import os.log

/// Decodes Dictionaries filtering invalid key-value pairs if applicable.
/// `@LossyDictionary` decodes Dictionaries and filters invalid key-value pairs
/// if the Decoder is unable to decode the value.
/// This is useful if the Dictionary is intended to contain non-optional values.
///
/// Based on https://github.com/marksands/BetterCodable/blob/master/Sources/BetterCodable/LossyDictionary.swift

@propertyWrapper
public struct LossyDictionary <Key, Value>: Sendable
	where Key: Hashable,
		  Key: Sendable,
		  Value: Sendable
{
	public var wrappedValue: [Key: Value]
	
	public init(wrappedValue: [Key: Value]) {
		self.wrappedValue = wrappedValue
	}
}

fileprivate final actor LossyDictionaryLogger {
	fileprivate static let shared = LossyDictionaryLogger()
	
	fileprivate var level: DebugDepth = .minimum
	fileprivate let logger = Logger(
		subsystem: "Coding",
		category: "Lossy Dictionary"
	)
	
	fileprivate func setLogLevel(_ level: DebugDepth) {
		self.level = level
	}
	
	fileprivate func logger(when debug: DebugDepth) -> Logger? {
		if self.level >= debug {
			logger
		} else {
			.none
		}
	}
}

extension LossyDictionary: Decodable where Key: Decodable, Value: Decodable {
	private struct AnyDecodableValue: Decodable {}
	private struct LossyDecodableValue<Wrapped: Decodable>: Decodable {
		let value: Wrapped
		
		public init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()
			value = try container.decode(Wrapped.self)
		}
	}
	
	public init(from decoder: Decoder) throws {
		var elements: [Key: Value] = .empty
		do {
			if Key.self == String.self {
				let container = try decoder.container(keyedBy: JSONCodingKeys.self)
				let keys = try Self.extractKeys(from: decoder, container: container)

				for (key, stringKey) in keys {
					do {
						let value = try container.decode(LossyDecodableValue<Value>.self, forKey: key).value
						elements[stringKey as! Key] = value
					} catch let error as DecodingError {
						Task {
							await LossyDictionaryLogger.shared.logger(when: .default)?
								.warning("""
									Skipping \(Value.self) element while decoding
									┗ \(error.humanReadableDescription)
									""")
						}
						_ = try? container.decode(AnyDecodableValue.self, forKey: key)
					} catch {
						Task {
							await LossyDictionaryLogger.shared.logger(when: .default)?
								.warning("Skipping \(Value.self) element while decoding. \(error)")
						}
						_ = try? container.decode(AnyDecodableValue.self, forKey: key)
					}
				}
			} else if Key.self == Int.self {
				let container = try decoder.container(keyedBy: JSONCodingKeys.self)
				
				for key in container.allKeys {
					guard key.intValue != nil else {
						var codingPath = decoder.codingPath
						codingPath.append(key)
						throw DecodingError.typeMismatch(
							Int.self,
							DecodingError.Context(
								codingPath: codingPath,
								debugDescription: "Expected Int key but found String key instead."
							)
						)
					}
					
					do {
						let value = try container.decode(LossyDecodableValue<Value>.self, forKey: key).value
						elements[key.intValue! as! Key] = value
					} catch let error as DecodingError {
						Task {
							await LossyDictionaryLogger.shared.logger(when: .default)?
								.warning("""
									Skipping \(Value.self) element while decoding
									┗ \(error.humanReadableDescription)
									""")
						}
						_ = try? container.decode(AnyDecodableValue.self, forKey: key)
					} catch {
						Task {
							await LossyDictionaryLogger.shared.logger(when: .default)?
								.warning("Skipping \(Value.self) element while decoding. \(error)")
						}
						_ = try? container.decode(AnyDecodableValue.self, forKey: key)
					}
				}
			} else {
				 throw DecodingError.dataCorrupted(
						DecodingError.Context(
							codingPath: decoder.codingPath,
							debugDescription: "Unable to decode key type."
						)
				 )
			}
		} catch let error as DecodingError {
			Task {
				await LossyDictionaryLogger.shared.logger(when: .default)?
					.warning("""
						Skipping the whole non-dictionary
						┗ \(error.humanReadableDescription)
						""")
			}
		} catch {
			Task {
				await LossyDictionaryLogger.shared.logger(when: .default)?
					.error("Non-dictionary skipped. \(error)")
			}
		}
		
		self.wrappedValue = elements
	}

	private static func extractKeys(
		from decoder: Decoder,
		container: KeyedDecodingContainer<JSONCodingKeys>
	) throws -> [(JSONCodingKeys, String)] {
		// Decode a dictionary ignoring the values to decode the original keys
		// without using the `JSONDecoder.KeyDecodingStrategy`.
		let keys = try decoder.singleValueContainer().decode([String: AnyDecodableValue].self).keys

		return zip(
			container.allKeys.sorted(by: { $0.stringValue < $1.stringValue }),
			keys.sorted()
		)
		.map { ($0, $1) }
	}
}

extension LossyDictionary: Encodable where Key: Encodable, Value: Encodable {
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
}

extension LossyDictionary: Equatable where Value: Equatable { }

extension LossyDictionary: Hashable where Value: Hashable { }
