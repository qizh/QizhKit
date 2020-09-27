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

public protocol PriceDetailsProvider {
	var currency: Price.Code { get }
	var discount: Decimal { get }
	var tax: Decimal { get }
}

//public typealias PriceValueAndDetailsProvider = PriceValueProvider & PriceDetailsProvider

// MARK: Price

public struct Price:
	Price.Provider,
	Equatable,
	Updatable
{
	public typealias Provider = PriceValueProvider & PriceDetailsProvider
	public typealias Code = AnyCurrencyCode
	
	public private(set) var value: 		Decimal
	public private(set) var currency: 	Code
	public private(set) var discount: 	Decimal
	public private(set) var tax: 		Decimal
	
	/// - Parameter currencyCode: ISO 4217 currency code
    public init(
		   value: Decimal = .zero,
		currency: Code = .default,
		discount: Decimal = .zero,
		     tax: Decimal = .zero
	) {
    	self.value    = value
		self.currency = currency
		self.discount = discount
		self.tax      = tax
    }
	
	@inlinable public init(_ value: Decimal, _ currency: Code = .default) {
		self.init(value: value, currency: currency)
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

// MARK: Service Charge

public extension Price {
	struct Service: PriceValueProvider, PriceDetailsProvider {
		public let value: Decimal
		public let currency: Code
		public let discount: Decimal = .zero
		public let tax: Decimal = .zero
		
		public init(_ value: Decimal, _ currency: Code = .default) {
			self.value = value
			self.currency = currency
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
	@inlinable func formatted(_ locale: Locale) -> Formatted { Formatted(self, locale: locale) }
	@inlinable func formatted(or free: String, _ locale: Locale) -> Formatted { Formatted(self, or: free, locale: locale) }

	struct Formatted {
		public let price: Price
		public let free: String?
		public let unit: PriceUnit.AnyValue
		public let locale: Locale
		
		public init(
			 _ price: Price,
			for unit: PriceUnit.AnyValue = .default,
			 or free: String? = nil,
			  locale: Locale
		) {
			self.price = price
			self.unit = unit
			self.free = free
			self.locale = locale
		}
		
		public var currency: String {
			if price.isFree, let free = free { return free }
			return price.currency.string(for: price.value, locale)
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
