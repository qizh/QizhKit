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
	var taxes: 	 [Price.Output]  { get }
	var discount: Price.Output   { get }
	var flatDiscount: Price.Output { get }
	var service:  Price.Output   { get }
	var total: 	  Price.Output   { get }
	var roundedTotal: Price.Output { get }
	var price:    Price.Provider { get }
}

public extension PriceCalculationProvider {
	@inlinable static var zero: Price.CalculatedItem { .init(Price.zero, .zero) }
	@inlinable var isZero: Bool { all.isZero }
	@inlinable var isNotZero: Bool { not(isZero) }
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
		
		private func output(_ value: Decimal, _ name: String) -> Output {
			Output(value: value, details: price, amount: amount, name: name)
		}
		
		public var unit: 		 Output { output(price.value, "One item") }
		public var all: 		 Output { output(price.value * Decimal(amount), "All items") }
		public var taxes: 		[Output] {
			price.taxes.map { tax in
				switch tax {
				case let .flat(value, name): return output(value, name)
				case let .percent(value, name): return output(value, name)
				}
			}
		}
		public var discount: 	 Output { output(price.discount.percent, "Discount percent") }
		public var flatDiscount: Output { output(price.discount.flat, "Discount value") }
		public var service: 	 Output { output(.zero, "Service Fee") }
		public var total: 		 Output { all.discounted.taxed }
		public var roundedTotal: Output {
			all.roundedDiscounted.roundedTaxed
		}
		
		public static func == (l: Price.CalculatedItem, r: Price.CalculatedItem) -> Bool {
			l.amount == r.amount &&
			l.price.value == r.price.value &&
			l.price.currency == r.price.currency &&
			l.price.taxes == r.price.taxes &&
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
			Output(value: price.value, details: price, amount: .one, name: "Service Fee")
		}
		
		private var zero: Output {
			Output(value: .zero, details: price, amount: .one, name: "Service Fee")
		}
		
		public var unit: 		 Output  { value }
		public var all: 		 Output  { zero }
		public var taxes: 		[Output] { .empty }
		public var discount: 	 Output  { zero }
		public var flatDiscount: Output  { zero }
		public var service: 	 Output  { value }
		public var total: 		 Output  { value }
		public var roundedTotal: Output  { value }
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
		public let name: String
		
		fileprivate init(
			value: Decimal,
			details: Details,
			amount: UInt,
			name: String
		) {
			self.value = value
			self.details = details
			self.amount = amount
			self.name = name
		}
		
		public var decimal: Decimal { value }
		public var cents: Int { value.cents }
		
		/// - Warning: Dynamic positioning and autoupdating locale,
		/// please use `.format(as:position:for:)`
		@inlinable public var formatted: String {
			format(as: .string, position: .dynamic, for: .autoupdatingCurrent)
		}
		
		/// - Warning: Dynamic positioning and autoupdating locale,
		/// please use `.format(as:position:for:)`
		@inlinable public var formattedPercents: String {
			format(as: .percent, position: .dynamic, for: .autoupdatingCurrent)
		}
		
		/// - Warning: Dynamic positioning and autoupdating locale,
		/// please use `.format(as:position:for:)`
		@inlinable public var formattedCurrency: String {
			format(as: .currency, position: .dynamic, for: .autoupdatingCurrent)
		}
		
		/// - Warning: Dynamic positioning and autoupdating locale,
		/// please use `.format(as:position:for:)`
		@inlinable public var formattedCurrencyOrEmpty: String {
			format(as: .currencyOrEmpty, position: .dynamic, for: .autoupdatingCurrent)
		}
		
		public func format(
			as formatType: FormatType,
			position context: Formatter.Context,
			for locale: Locale
		) -> String {
			switch formatType {
			case .currency(let free) where free.isSet:
				return
					(value.nonZero?.format(
						as: .currency(details.currency.code),
						position: context,
						for: locale
					))
					.or(free.forceUnwrap(because: "switch case condition"))
			case .currency:
				return value.format(
					as: .currency(details.currency.code),
					position: context,
					for: locale
				)
			case .string:
				return value.format(
					as: .string,
					position: context,
					for: locale
				)
			case .percent:
				return value.format(
					as: .percent,
					position: context,
					for: locale
				)
			}
		}
		
		private func calculate(
			_ value: Decimal,
			_ name: String,
			rounded: Bool = false
		) -> Output {
			Output(
				value: rounded
					? value.rounded(details.currency.roundingScale, .bankers)
					: value,
				details: details,
				amount: amount,
				name: name
			)
		}
		
		public var discount: Output {
			calculate(
				value * details.discount.percent.percents + details.discount.flat,
				"Discount"
			)
		}
		
		public var roundedDiscount: Output {
			calculate(
				value * details.discount.percent.percents + details.discount.flat,
				"Discount",
				rounded: true
			)
		}
		
		public var discounted: Output {
			calculate(value - discount.value, "Discounted")
		}
		
		public var roundedDiscounted: Output {
			calculate(value - roundedDiscount.value, "Discounted")
		}
		
		public var taxes: [Output] {
			details.taxes.map { tax in
				switch tax {
				case let .flat(amount, name): return calculate(amount, name)
				case let .percent(percent, name): return calculate(value * percent.percents, name)
				}
			}
		}
		
		/// Sum of all taxes
		public var tax: Output {
			taxes.reduce(.zero(details), +)
		}
		
		public var taxed: Output {
			calculate(
				taxes
					.map(\.value)
					.reduce(value, +),
				"Taxed"
			)
		}
		
		public var roundedTaxes: [Output] {
			details.taxes.map { tax in
				switch tax {
				case let .flat(amount, name):
					return calculate(amount, name, rounded: true)
				case let .percent(percent, name):
					return calculate(value * percent.percents, name, rounded: true)
				}
			}
		}
		
		public var roundedTax: Output {
			roundedTaxes.reduce(.zero(details), +)
		}
		
		public var roundedTaxed: Output {
			calculate(
				roundedTaxes
					.map(\.value)
					.reduce(value, +),
				"Taxed"
			)
		}
		
		public var negated: Output { calculate(value.negated, name) }
		
		/// When the value is 0 or the amount is 0
		public var isFree: Bool { value.isZero || amount.isZero }
		
		/// When the value is not 0 and the amount is not 0
		public var nonFree: Output? { isFree ? nil : self }
		
		/// When the value is 0. Amount could be non-zero.
		/// For example 2 items $0 each
		public var isZero: Bool { value.isZero }
		@inlinable public var isNotZero: Bool { not(isZero) }
		
		/// When the value is not 0, amount could be zero
		public var nonZero: Output? { isZero ? nil : self }
		
		public static func zero(_ details: Details) -> Output {
			Output(value: .zero, details: details, amount: .zero, name: "Zero")
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
				amount: l.amount + r.amount,
				name: l.name + .space + r.name
			)
		}
		
		public static func + (l: Output, r: Decimal) -> Output {
			Output(
				value: l.value + r,
				details: l.details,
				amount: l.amount,
				name: l.name
			)
		}
	}
	
	@inlinable func calculate(for amount: UInt) -> CalculatedItem {
		CalculatedItem(self, amount)
	}
	
	/*
	@inlinable func calculate(for amount: UInt, service: Service) -> CalculatedSum {
		CalculatedItem(self, amount) + service.calculated
	}
	*/
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
		
		public var unit: Output         { firstWithPrice.unit }
		public var all: Output          { items.map(\.all)         .reduce(zero, +) }
		public var taxes: [Output]      { items.map(\.taxes).joined().asArray() }
		public var discount: Output     { items.map(\.discount)    .reduce(zero, +) }
		public var flatDiscount: Output { items.map(\.flatDiscount).reduce(zero, +) }
		public var service: Output      { items.map(\.service)     .reduce(zero, +) }
		public var total: Output        { items.map(\.total)       .reduce(zero, +) }
		public var roundedTotal: Output { items.map(\.roundedTotal).reduce(zero, +) }
		
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
