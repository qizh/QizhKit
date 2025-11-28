//
//  LossyArray.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.10.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation
import os.log

fileprivate final actor LossyArrayLogger {
	fileprivate static let shared = LossyArrayLogger()
	
	fileprivate var level: DebugDepth = .minimum
	fileprivate let logger = Logger(
		subsystem: "Coding",
		category: "Lossy Array"
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

/// Decodes Arrays and filters invalid values if the Decoder is unable to decode the value.
@propertyWrapper
public struct LossyArray <Item: Codable>: Codable, ExpressibleByArrayLiteral {
	public var wrappedValue: [Item]
	
	public init(wrappedValue: [Item] = .empty) {
		self.wrappedValue = wrappedValue
	}
	
	public init(arrayLiteral elements: Item...) {
		self.wrappedValue = elements
	}
	
	public init(from decoder: Decoder) throws {
		var elements: [Item] = .empty
		
		do {
			var container = try decoder.unkeyedContainer()
			while !container.isAtEnd {
				do {
					let value = try container.decode(Item.self)
					elements.append(value)
					// logger.debug("[LossyArray] decoded \(Item.self) element")
				} catch let error as DecodingError {
					Task {
						await LossyArrayLogger.shared.logger(when: .default)?
							.warning("""
								Skipping \(Item.self) element while decoding
								┗ \(error.humanReadableDescription)
								""")
					}
					_ = try? container.decode(Blancodable.self)
				} catch {
					Task {
						await LossyArrayLogger.shared.logger(when: .default)?
							.warning("Skipping \(Item.self) element while decoding. \(error)")
					}
					_ = try? container.decode(Blancodable.self)
				}
			}
		} catch let error as DecodingError {
			Task {
				await LossyArrayLogger.shared.logger(when: .default)?
					.warning("""
						Skipping the whole non-array
						┗ \(error.humanReadableDescription)
						""")
			}
		} catch {
			Task {
				await LossyArrayLogger.shared.logger(when: .default)?
					.warning("Non-array skipped: \(error)")
			}
		}
		
		self.wrappedValue = elements
	}
	
	@inlinable
	public static func some(_ elements: Item...) -> Self {
		.init(wrappedValue: elements)
	}
	
	@inlinable
	public static func some(_ elements: [Item]) -> Self {
		.init(wrappedValue: elements)
	}
	
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
	
	private struct Blancodable: Codable { }
}

extension LossyArray {
	@inlinable public var count: Int { wrappedValue.count }
}

extension LossyArray: WithDefault {
	@inlinable public static var `default`: Self { .init() }
}

extension LossyArray: EmptyComparable {
	@inlinable public static var empty: Self { .init() }
	@inlinable public var isEmpty: Bool { wrappedValue.isEmpty }
}

extension LossyArray: Equatable where Item: Equatable { }
extension LossyArray: Hashable where Item: Hashable { }
extension LossyArray: Sendable where Item: Sendable { }

public extension KeyedDecodingContainer {
	func decode <Wrapped: Codable> (
		_: LossyArray<Wrapped>.Type,
		forKey key: Key
	) -> LossyArray<Wrapped> {
		let result: LossyArray<Wrapped>?
		do {
			// print("[LossyArray] try to decode \(Wrapped.self) optionally")
			result = try decodeIfPresent(LossyArray<Wrapped>.self, forKey: key)
		} catch {
			Task {
				await LossyArrayLogger.shared.logger(when: .default)?
					.warning("No value for \"\(key)\" key")
			}
			result = nil
		}
		/*
		if let count = result?.wrappedValue.count {
			print("[LossyArray] decoded \(count) \(Wrapped.self) elements")
		} else {
			print("[LossyArray] failed to decode any \(Wrapped.self), fallback to default")
		}
		*/
		return result.orDefault
	}
}
