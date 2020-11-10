//
//  Optional+mapView.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Builders

public extension Optional {
	typealias ContentBuilder <Content: View> = () -> Content
	typealias OptionalContentBuilder <Content: View> = () -> Content?
	typealias ValueContentBuilder <Value, Content: View> = (Value) -> Content?
}

// MARK: View

public extension Optional {
	@inlinable func mapView <Content: View> (
		@ViewBuilder _ content: ValueContentBuilder<Wrapped, Content>
	) -> Content? {
		switch self {
		case .none: return nil
		case .some(let value): return content(value)
		}
	}
	
	@inlinable func map <Content: View> (
		@ViewBuilder view content: ValueContentBuilder<Wrapped, Content>
	) -> Content? {
		switch self {
		case .none: return nil
		case .some(let value): return content(value)
		}
	}
	
	@inlinable func cleanMapView <Content: View> (
		@ViewBuilder _ content: ContentBuilder<Content>
	) -> Content? {
		isSet ? content() : nil
	}
	
	@inlinable func cleanMap <Content: View> (
		@ViewBuilder view content: ContentBuilder<Content>
	) -> Content? {
		isSet ? content() : nil
	}
	
	@inlinable func cleanMapView <Content: View> (
		_ content: Content
	) -> Content? {
		isSet ? content : nil
	}
	
	@inlinable func cleanMap <Content: View> (
		view content: Content
	) -> Content? {
		isSet ? content : nil
	}
}

// MARK: ?? operator

public extension Optional where Wrapped: View {
	@inlinable static
	func ?? <Other: View> (
		lhs: Self,
		rhs: Other?
	)
		-> _ConditionalContent<Wrapped, Other?>
	{
		if let wrapped = lhs {
			return ViewBuilder.buildEither(first: wrapped)
		} else {
			return ViewBuilder.buildEither(second: rhs)
		}
	}
	
	@inlinable static
	func ?? <Other: View> (
		lhs: Self,
		rhs: Other
	)
		-> _ConditionalContent<Wrapped, Other>
	{
		if let wrapped = lhs {
			return ViewBuilder.buildEither(first: wrapped)
		} else {
			return ViewBuilder.buildEither(second: rhs)
		}
	}
}

// MARK: Text View

public extension Optional where Wrapped: StringProtocol, Wrapped: EmptyTestable {
	func mapText() -> Text? {
		switch self {
		case .some(let label) where label.isNotEmpty: return Text(label)
		default: return nil
		}
	}
}

// MARK: > for KeyPath

public extension Optional {
	func mapText <S: StringProtocol & EmptyTestable> (for key: KeyPath<Wrapped, S>) -> Text? {
		if let wrapped = self {
			let text: S = wrapped[keyPath: key]
			if text.isNotEmpty {
				return Text(text)
			}
		}
		return nil
	}
	
	func mapText <S: StringProtocol & EmptyTestable> (for key: KeyPath<Wrapped, S?>) -> Text? {
		if let wrapped = self,
		   let text: S = wrapped[keyPath: key],
		   text.isNotEmpty
		{
			return Text(text)
		}
		return nil
	}
}

// MARK: Empty View

public extension Optional {
	/// Maps an optional to an `EmptyView()`.
	/// Used for creating another view in case there's no value.
	/// - Returns: An `EmptyView()` when there's a value,
	/// `nil` when there's no value.
	func mapEmpty() -> EmptyView? {
		switch self {
		case .some: return EmptyView()
		case .none: return nil
		}
	}
}

// MARK: Bool

public extension Bool {
	@inlinable func then <Output: View> (
		@ViewBuilder view build: () -> Output
	) -> Output? {
		self ? build() : nil
	}
	
	@inlinable func then <Output: View> (
		view: Output
	) -> Output? {
		self ? view : nil
	}
	
	@inlinable func otherwise <Output: View> (
		@ViewBuilder view build: () -> Output
	) -> Output? {
		self ? nil : build()
	}
	
	@inlinable func otherwise <Output: View> (
		view: Output
	) -> Output? {
		self ? nil : view
	}
}

// MARK: Map 2

public extension Optional {
	@inlinable func map <Out, Second> (
		_ transform: (Wrapped, Second) -> Out,
		_ second: Second
	) -> Out? {
		switch self {
		case .none: return nil
		case .some(let wrapped): return transform(wrapped, second)
		}
	}
	
	@inlinable func map <Out, Second> (
		_ transform: (Wrapped, Second) -> Out,
		_ second: Second?
	) -> Out? {
		switch (self, second) {
		case (.some(let wrapped), .some(let second)):
			return transform(wrapped, second)
		default: return nil
		}
	}
	
	@inlinable func map <Out, Second> (
		_ transform: (Wrapped, Second?) -> Out,
		_ second: Second?
	) -> Out? {
		switch self {
		case .none: return nil
		case .some(let wrapped): return transform(wrapped, second)
		}
	}
	
	// MARK: > Reversed
	
	@inlinable func map <Out, First> (
		_ first: First,
		_ transform: (First, Wrapped) -> Out
	) -> Out? {
		switch self {
		case .none: return nil
		case .some(let wrapped): return transform(first, wrapped)
		}
	}
	
	@inlinable func map <Out, First> (
		_ first: First?,
		_ transform: (First, Wrapped) -> Out
	) -> Out? {
		switch (self, first) {
		case (.some(let wrapped), .some(let first)):
			return transform(first, wrapped)
		default: return nil
		}
	}
	
	@inlinable func map <Out, First> (
		_ first: First?,
		_ transform: (First?, Wrapped) -> Out
	) -> Out? {
		switch self {
		case .none: return nil
		case .some(let wrapped): return transform(first, wrapped)
		}
	}
}

// MARK: Map View 2

public extension Optional {
	@inlinable func map <Out: View, Second> (
		@ViewBuilder view builder: (Wrapped, Second) -> Out,
		_ second: Second
	) -> Out? {
		switch self {
		case .none: return nil
		case .some(let wrapped): return builder(wrapped, second)
		}
	}
	
	@inlinable func map <Out: View, Second> (
		@ViewBuilder view builder: (Wrapped, Second) -> Out,
		_ second: Second?
	) -> Out? {
		switch (self, second) {
		case (.some(let wrapped), .some(let second)):
			return builder(wrapped, second)
		default: return nil
		}
	}
	
	@inlinable func map <Out: View, Second> (
		@ViewBuilder view builder: (Wrapped, Second?) -> Out,
		_ second: Second?
	) -> Out? {
		switch self {
		case .none: return nil
		case .some(let wrapped): return builder(wrapped, second)
		}
	}
	
	// MARK: > Reversed
	
	@inlinable func map <Out: View, First> (
		_ first: First,
		@ViewBuilder view builder: (First, Wrapped) -> Out
	) -> Out? {
		switch self {
		case .none: return nil
		case .some(let wrapped): return builder(first, wrapped)
		}
	}
	
	@inlinable func map <Out: View, First> (
		_ first: First?,
		@ViewBuilder view builder: (First, Wrapped) -> Out
	) -> Out? {
		switch (self, first) {
		case (.some(let wrapped), .some(let first)):
			return builder(first, wrapped)
		default: return nil
		}
	}
	
	@inlinable func map <Out: View, First> (
		_ first: First?,
		@ViewBuilder view builder: (First?, Wrapped) -> Out
	) -> Out? {
		switch self {
		case .none: return nil
		case .some(let wrapped): return builder(first, wrapped)
		}
	}
}
