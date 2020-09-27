//
//  CalculatedPrice.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 08.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Protocols

public protocol PriceCalculationProvider {
	var unit: 	  Price.Output   { get }
	var all: 	  Price.Output   { get }
	var tax: 	  Price.Output   { get }
	var discount: Price.Output   { get }
	var service:  Price.Output   { get }
	var total: 	  Price.Output   { get }
	var price:    Price.Provider { get }
}

// MARK: Calculated

public extension Price {
	typealias Calculated = PriceCalculationProvider
	struct CalculatedItem: Calculated {
		public let price: Price.Provider
		fileprivate let amount: UInt
		
		public init(
			_ price: Price.Provider,
			_ amount: UInt
		) {
			self.price = price
			self.amount = amount
		}
		
		private func output(_ value: Decimal) -> Output {
			Output(value: value, details: price, amount: amount)
		}
		
		public var unit: 		Output { output(price.value) }
		public var all: 		Output { output(price.value * Decimal(amount)) }
		public var tax: 		Output { output(price.tax) }
		public var discount: 	Output { output(price.discount) }
		public var service: 	Output { output(.zero) }
		public var total: 		Output { all.discounted.taxed }
		
		public static func == (l: Price.CalculatedItem, r: Price.CalculatedItem) -> Bool {
			l.amount == r.amount &&
			l.price.value == r.price.value &&
			l.price.currency == r.price.currency &&
			l.price.tax == r.price.tax &&
			l.price.discount == r.price.discount
		}
	}
}

public extension Price {
	struct CalculatedService: Calculated {
		public let price: Price.Provider
		
		public init(_ price: Service) {
			self.price = price
		}
		
		private var value: Output {
			Output(value: price.value, details: price, amount: .one)
		}
		
		private var zero: Output {
			Output(value: .zero, details: price, amount: .one)
		}
		
		public var unit: 		Output { value }
		public var all: 		Output { zero }
		public var tax: 		Output { zero }
		public var discount: 	Output { zero }
		public var service: 	Output { value }
		public var total: 		Output { value }
	}
}

public extension Price.Service {
	var calculated: Price.CalculatedService { .init(self) }
}

// MARK: > Output

public extension Price {
	struct Output {
		public typealias Details = PriceDetailsProvider
		
		private let value: Decimal
		private let details: Details
		private let amount: UInt
		
		fileprivate init(
			value: Decimal,
			details: Details,
			amount: UInt
		) {
			self.value = value
			self.details = details
			self.amount = amount
		}
		
		public var decimal: Decimal { value }
		public var cents: Int { ((.hundred * value) as NSDecimalNumber).intValue }
		
		@inlinable public var formatted: String { format(as: .string) }
		@inlinable public var formattedPercents: String { format(as: .percent) }
		@inlinable public var formattedCurrency: String { format(as: .currency) }
		@inlinable public var formattedCurrencyOrEmpty: String { format(as: .currencyOrEmpty) }
		
		public func format(as formatType: FormatType, _ locale: Locale = .current) -> String {
			switch formatType {
			case .currency(let free) where free.isSet:
				return
					(value.nonZero?.format(as: .currency(details.currency.code), locale))
					.or(free.forceUnwrap(because: "switch case condition"))
			case .currency: return value.format(as: .currency(details.currency.code), locale)
			case .string: 	return value.format(as: .string, locale)
			case .percent: 	return value.format(as: .percent, locale)
			}
		}
		
		private func calculate(_ value: Decimal) -> Output {
			Output(value: value, details: details, amount: amount)
		}
		
		public var discount: 	Output { calculate(value * details.discount.percents) }
		public var discounted: 	Output { calculate(value - discount.value) }
		public var tax: 		Output { calculate(value * details.tax.percents) }
		public var taxed: 		Output { calculate(value + tax.value) }
		public var negated: 	Output { calculate(value.negated) }
		
		/// When the value is 0 or the amount is 0
		public var isFree: Bool { value.isZero || amount.isZero }
		
		/// When the value is not 0 and the amount is not 0
		public var nonFree: Output? { isFree ? nil : self }
		
		/// When the value is 0. Amount could be non-zero.
		/// For example 2 items $0 each
		public var isZero: Bool { value.isZero }
		
		/// When the value is not 0, amount could be zero
		public var nonZero: Output? { isZero ? nil : self }
		
		public static func zero(_ details: Details) -> Output {
			Output(value: .zero, details: details, amount: .zero)
		}

		// MARK: > Format Type
		
		public enum FormatType {
			case string
			case percent
			case currency(free: String? = nil)
			
			public static let currency: Self = .currency(free: nil)
			public static let currencyOrEmpty: Self = .currency(free: .empty)
		}
		
		public static func + (l: Output, r: Output) -> Output {
			Output(
				value: l.value + r.value,
				details: l.details,
				amount: l.amount + r.amount
			)
		}
	}
	
	@inlinable func calculate(for amount: UInt) -> CalculatedItem {
		CalculatedItem(self, amount)
	}
	
	@inlinable func calculate(for amount: UInt, service: Service) -> CalculatedSum {
		CalculatedItem(self, amount) + service.calculated
	}
}

// MARK: Sum

public extension Price {
	struct CalculatedSum: Calculated, ExpressibleByArrayLiteral {
		fileprivate let items: [Calculated]
		
		@inlinable public init() { self.init(of: .empty) }
		@inlinable public init(_ items: Calculated ...) { self.init(of: items) }
		@inlinable public init(arrayLiteral items: Calculated ...) { self.init(of: items) }
		public init(of items: [Calculated]) { self.items = items }
		
//		public init(of items: [CalculatedSum])  { self.init(items) }
//		public init(of items: [CalculatedItem]) { self.init(items) }
		
		/*
		fileprivate var first: Calculated {
			   items.first
			?? CalculatedItem(Price.zero, .zero)
		}
		*/
		
		fileprivate var firstWithPrice: Calculated {
			   items.first(where: \.price.isNotZero)
			?? CalculatedItem(Price.zero, .zero)
		}
		fileprivate var zero: Output { .zero(price) }
		public var price: Price.Provider { firstWithPrice.price }
		
		public var unit: Output     { firstWithPrice.unit }
		public var all: Output      { items.map(\.all)     .reduce(zero, +) }
		public var tax: Output      { items.map(\.tax)     .reduce(zero, +) }
		public var discount: Output { items.map(\.discount).reduce(zero, +) }
		public var service: Output  { items.map(\.service) .reduce(zero, +) }
		public var total: Output    { items.map(\.total)   .reduce(zero, +) }

		public static let empty: CalculatedSum = .init()
	}
}

public extension Collection where Element: Price.Calculated {
	var sum: Price.CalculatedSum {
		Price.CalculatedSum(of: Array(self))
	}
}

// MARK: +

public extension Price.CalculatedItem {
	@inlinable static func + (l: Self, r: Price.Calculated) -> Price.CalculatedSum { [l, r] }
	/*
	typealias Summ = Price.CalculatedSum
	typealias Srvc = Price.CalculatedService
	static func + (l: Self, r: Self) -> Summ { .init([l, r]) }
	static func + (l: Self, r: Srvc) -> Summ { .init([l, r]) }
	static func + (l: Self, r: Summ) -> Summ { .init([l] + r.items) }
	*/
}

public extension Price.CalculatedService {
	@inlinable static func + (l: Self, r: Price.Calculated) -> Price.CalculatedSum { [l, r] }
	/*
	typealias Summ = Price.CalculatedSum
	typealias Item = Price.CalculatedItem
	static func + (l: Self, r: Self) -> Summ { [l, r] }
	static func + (l: Self, r: Item) -> Summ { .init([l, r]) }
	static func + (l: Self, r: Summ) -> Summ { .init([l] + r.items) }
	*/
}

public extension Price.CalculatedSum {
	@inlinable static func + (l: Self, r: Price.Calculated) -> Self { [l, r] }
}
