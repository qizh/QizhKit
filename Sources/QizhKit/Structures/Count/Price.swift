//
//  Price.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 08.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Protocol

public protocol PriceValueProvider {
	var value: Decimal { get }
}

public extension PriceValueProvider {
	@inlinable var isFree: Bool { value.isZero }
	@inlinable var isZero: Bool { value.isZero }
	@inlinable var isNotFree: Bool { !value.isZero }
	@inlinable var isNotZero: Bool { !value.isZero }
	@inlinable var nonFree: Self? { isFree ? nil : self }
	@inlinable var nonZero: Self? { isZero ? nil : self }
}

public protocol PriceDetailsProvider: Sendable {
	var currency: Price.Code { get }
	var discount: Price.Discount { get }
	var taxes: [Price.Tax] { get }
	func combined(with other: PriceDetailsProvider) -> PriceDetailsProvider
}

public protocol PriceValueAndDetailsProvider: PriceValueProvider, 
											  PriceDetailsProvider {
}

//public typealias PriceValueAndDetailsProvider = PriceValueProvider & PriceDetailsProvider

// MARK: Price

public struct Price:
	PriceValueAndDetailsProvider,
	Equatable,
	Updatable
{
	public typealias Provider = PriceValueAndDetailsProvider
	public typealias Code = AnyCurrencyCode
	
	public private(set) var value: 		Decimal
	public private(set) var currency: 	Code
	public private(set) var discount: 	Discount
	public private(set) var taxes: 		[Tax]
	
	/// - Parameter currencyCode: ISO 4217 currency code
    public init(
		   value: Decimal = .zero,
		currency: Code = .default,
		discount: Discount = .zero,
		   taxes: [Tax] = .empty
	) {
    	self.value    = value
		self.currency = currency
		self.discount = discount
		self.taxes    = taxes
    }
	
	public init(
		   value: Decimal = .zero,
		currency: Code = .default,
		discount: Discount = .zero,
		   taxes: Tax...
	) {
		self.value    = value
		self.currency = currency
		self.discount = discount
		self.taxes    = taxes
	}
	
	@inlinable public init(_ value: Decimal, _ currency: Code = .default) {
		self.init(value: value, currency: currency)
	}
	
	public func with(discount: Discount) -> Price {
		.init(
			value: value,
			currency: currency,
			discount: discount,
			taxes: taxes
		)
	}
	
	public func with(taxes: [Tax]) -> Price {
		.init(
			value: value,
			currency: currency,
			discount: discount,
			taxes: taxes
		)
	}
	
	public func combined(with other: PriceDetailsProvider) -> PriceDetailsProvider {
		var copy = self
		
		if copy.currency.code != other.currency.code,
		   not(other.currency.code.isEmpty)
		{
			if copy.currency.code.isEmpty {
				copy.currency = other.currency
			} else {
				print("Price warning: Skipped attempt to combine currency code \(currency.code) with \(other.currency.code)")
			}
		}
		
		if copy.discount != other.discount,
		   not(other.discount.isZero)
		{
			if copy.discount.isZero {
				copy.discount = other.discount
			} else {
				print("Price warning: Skipped attempt to combine discount \(copy.discount) with \(other.discount)")
			}
		}
		
		if copy.taxes != other.taxes,
		   not(other.taxes.isEmpty)
		{
			if copy.taxes.isEmpty {
				copy.taxes = other.taxes
			} else {
				print("Price warning: Combined unrelated taxes \(copy.taxes) with \(other.taxes)")
				copy.taxes += other.taxes
			}
		}
		
		return copy
	}
}

// MARK: Free

public extension Price {
	static let free: Price = Price(.zero)
	static let zero: Price = Price(.zero)
	@inlinable static func zero(_ currency: Code) -> Price { Price(.zero, currency) }
}

// MARK: +

extension Price {
	/*
	public static func + (l: Price, r: Price) -> Price {
		Price(
			value: 		l.value + r.value,
			currency: 	l.currency,
			discount: 	max(l.discount, r.discount),
			tax: 		min(l.tax, r.tax)
		)
	}
	*/
	public static func + (l: Price, r: Decimal) -> Price {
		l.updating(\.value).with(l.value + r)
	}
}

// MARK: Discount

public extension Price {
	enum Discount: Equatable, Sendable {
		case flat(_ value: Decimal)
		case percent(_ value: Decimal)
		
		public var flat: Decimal {
			switch self {
			case .flat(let value): return value
			case .percent(_): return .zero
			}
		}
		
		public var percent: Decimal {
			switch self {
			case .flat(_): return .zero
			case .percent(let value): return value
			}
		}
		
		public var amount: Decimal {
			switch self {
			case .flat(let value): return value
			case .percent(let value): return value
			}
		}
		
		public var isZero: Bool {
			switch self {
			case .flat(let value): return value.isZero
			case .percent(let value): return value.isZero
			}
		}
		
		public static let zero: Self = .flat(.zero)
	}
	
	var isDiscounted: Bool {
		discount.amount.isNotZero
	}
}

// MARK: Tax

public extension Price {
	enum Tax: Equatable, Sendable {
		case flat(_ value: Decimal, name: String = .empty)
		case percent(_ value: Decimal, name: String = .empty)
		
		public var flat: Decimal {
			switch self {
			case .flat(let value, _): return value
			case .percent(_, _): return .zero
			}
		}
		
		public var percent: Decimal {
			switch self {
			case .flat(_, _): return .zero
			case .percent(let value, _): return value
			}
		}
		
		public var amount: Decimal {
			switch self {
			case .flat(let value, _): return value
			case .percent(let value, _): return value
			}
		}
		
		public var name: String {
			switch self {
			case .flat(_, let name): return name
			case .percent(_, let name): return name
			}
		}
		
		public var isZero: Bool {
			switch self {
			case .flat(let value, _): return value.isZero
			case .percent(let value, _): return value.isZero
			}
		}
		
		public static let zero: Self = .flat(.zero)
	}
	
	var isTaxed: Bool {
		taxes.contains(where: \.amount.isNotZero)
	}
}

// MARK: Service Charge

public extension Price {
	struct Service: Price.Provider {
		public let value: Decimal
		public let currency: Code
		public let discount: Discount = .zero
		public let taxes: [Tax] = .empty
		
		public init(_ value: Decimal, _ currency: Code = .default) {
			self.value = value
			self.currency = currency
		}
		
		public var asPrice: Price {
			Price(
				value: value,
				currency: currency,
				discount: discount,
				taxes: taxes
			)
		}
		
		@inlinable
		public func combined(with other: PriceDetailsProvider) -> PriceDetailsProvider {
			self.asPrice.combined(with: other)
		}
	}
}

public extension Price.Service {
	static let zero: Self = .init(.zero)
	@inlinable static func zero(_ currency: Price.Code) -> Self { .init(.zero, currency) }
}

public typealias ServiceCharge = Price.Service

// MARK: Format

public extension Price {
	@inlinable func formatted(
		unit: PriceUnit.AnyValue = .default,
		position context: Formatter.Context,
		for locale: Locale
	) -> Formatted {
		Formatted(self, for: unit, position: context, locale: locale)
	}
	
	@inlinable func formatted(
		unit: PriceUnit.AnyValue = .default,
		or free: String,
		position context: Formatter.Context,
		for locale: Locale
	) -> Formatted {
		Formatted(self, for: unit, or: free, position: context, locale: locale)
	}

	struct Formatted {
		public let price: Price
		public let free: String?
		public let unit: PriceUnit.AnyValue
		public let context: Formatter.Context
		public let locale: Locale
		
		public init(
			 _ price: Price,
			for unit: PriceUnit.AnyValue = .default,
			 or free: String? = nil,
			position context: Formatter.Context,
			  locale: Locale
		) {
			self.price = price
			self.unit = unit
			self.free = free
			self.context = context
			self.locale = locale
		}
		
		public var currency: String {
			if price.isFree, let free = free { return free }
			return price.currency
				.string(
					for: price.value,
					position: context,
					in: locale,
					alwaysShowFraction: false
				)
		}
		
		public func separated(by separator: UnitSeparator) -> String {
			if price.isFree, let free = free { return free }
			return currency + separator.rawValue + unit.rawValue
		}
	}
}

extension Price.Formatted: CustomStringConvertible, TextOutputStreamable {
	@inlinable public var description: String { currency }
	public func write<Target>(to target: inout Target) where Target: TextOutputStream {
		target.write(currency)
	}
}

// MARK: Separator

public extension Price.Formatted {
	enum UnitSeparator: String {
		case slash = "/"
		case per = " per "
	}
}

public typealias PriceUnitSeparator = Price.Formatted.UnitSeparator

// MARK: SwiftUI

import SwiftUI

extension Price {
	@available(iOS 15.0, *)
	public func formattedCurrencyText(
		precision: Decimal.FormatStyle.Currency.Configuration.Precision = .fractionLength(0...),
		locale: Locale
	) -> Text {
		Text(value, format: .currency(code: currency.code)
							.precision(precision)
							.locale(locale))
	}
}
