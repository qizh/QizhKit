//
//  CollectionAnchor.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 06.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public enum CollectionAnchor <Source>
	where
	Source: BidirectionalCollection,
	Source: RangeReplaceableCollection,
	Source.Element: Equatable
{
	public typealias Element = Source.Element
	public typealias Sub 	 = Source.SubSequence
	public typealias Index   = Source.Index
	
	case starting(with: Order, _ elements: Source)
	case    after(      Order, _ elements: Source)
	case   ending(with: Order, _ elements: Source)
	case   before(      Order, _ elements: Source)
	
	@inlinable public static
	func starting(with o: Order, _ e: Element) -> Self { .starting(with: o, .just(e)) }
	@inlinable public static
	func    after(   _ o: Order, _ e: Element) -> Self { .after(o, .just(e)) }
	@inlinable public static
	func   ending(with o: Order, _ e: Element) -> Self { .ending(with: o, .just(e)) }
	@inlinable public static
	func   before(   _ o: Order, _ e: Element) -> Self { .before(o, .just(e)) }
	
	public enum Order: EasyCaseComparable {
		case first
		case last
	}
	
	public enum Interest: EasyCaseComparable {
		case match
		case whatsleft
	}
	
	public enum Side: EasyCaseComparable {
		case start
		case end
	}
	
	public enum Part: EasyCaseComparable {
		case prefix
		case suffix
	}
	
	@inlinable public var element: Element? { elements.only }
	public var elements: Source {
		switch self {
		case .starting(_, let e): return e
		case    .after(_, let e): return e
		case   .ending(_, let e): return e
		case   .before(_, let e): return e
		}
	}
	
	public var order: Order {
		switch self {
		case .starting(let o, _): return o
		case    .after(let o, _): return o
		case   .ending(let o, _): return o
		case   .before(let o, _): return o
		}
	}
	
	public var part: Part {
		switch self {
		case .starting: return .suffix
		case    .after: return .suffix
		case   .ending: return .prefix
		case   .before: return .prefix
		}
	}
	
	public var include: Bool {
		switch self {
		case .starting: return true
		case    .after: return false
		case   .ending: return true
		case   .before: return false
		}
	}
	
	/*
	public var greedy: Bool {
		part.is(.suffix) ⊻ order.is(.last)
	}
	*/
	
	public func range(
		of element: Element,
		 in source: Source
	) -> Range<Index>? {
		guard let lower = order.is(.first)
			? source.firstIndex(of: element)
			: source .lastIndex(of: element)
		else { return nil }
		let higher = source.index(after: lower)
		return lower ..< higher
	}
	
	public func range(
		of elements: Source,
		  in source: Source
	) -> Range<Index>?
		where Source: StringProtocol
	{
		order.is(.first)
			? source.range(of: elements)
			: source.range(of: elements, options: .backwards)
	}
	
	public func range(
		of elements: Source,
		  in source: Source
	) -> Range<Index>? {
		let text = source
			.map { String(reflecting: $0) }
			.joined(separator: separator)
		
		let phrase = elements
			.map { String(reflecting: $0) }
			.joined(separator: separator)
		
		guard let range = order.is(.first)
			? text.range(of: phrase)
			: text.range(of: phrase, options: .backwards)
		else { return nil }
		
		let prefixSeparatorsCount = text
			.prefix(through: range.lowerBound)
			.count(of: separator)
		
		let lowerBound = source.index(source.startIndex, offsetBy: prefixSeparatorsCount)
		let upperBound = source.index(lowerBound, offsetBy: elements.count)
		
		return lowerBound ..< upperBound
	}
	
	@inlinable public func start(of source: Source, _ interest: Interest) -> Index {
		index(for: interest, .start, in: source)
	}
	
	@inlinable public func end(of source: Source, _ interest: Interest) -> Index {
		index(for: interest, .end, in: source)
	}
	
	public func index(
		for interest: Interest,
		      _ side: Side,
		   in source: Source
	) -> Index {
		let mxe = interest.in(.match) ⊻ side.in(.end)
		
		if mxe ⊻ part.is(.suffix) {
			switch side {
			case .start: return source.startIndex
			case .end: return source.endIndex
			}
		}
		
		let range = elements.isAlone
			? self.range(of: element.forceUnwrapBecauseTested(), in: source)
			: self.range(of: elements, in: source)
		
		let bound = include ⊻ mxe
			? range?.upperBound
			: range?.lowerBound
		
		let fallback = { mxe
			? source.endIndex
			: source.startIndex
		}
		
		return bound ?? fallback()
	}
	
	public func find(
		_ interest: Interest,
		 in source: Source
	) -> Sub {
		source[start(of: source, interest) ..< end(of: source, interest)]
		/*
		let lower = index(for: interest, .start, in: source)
		let upper = index(for: interest, .end,   in: source)
		*/
		/*
		let lower = start(of: interest, in: source)
		let upper =   end(of: interest, in: source)
		return source[lower ..< upper]
		*/
	}
	
	@inlinable public func left(from source: Source) -> Sub {
		find(.whatsleft, in: source)
	}
	
	@inlinable public func match(in source: Source) -> Sub {
		find(.match, in: source)
	}
	
	public func replacing(
		in source: Source,
		with replacement: Source
	) -> Source where Source: Equatable {
		let remains: Source = Source(left(from: source))
		if remains != source {
			switch part {
			case .prefix: return replacement + remains
			case .suffix: return remains + replacement
			}
		}
		return source
	}
}

fileprivate let separator: String = "|><|"

public extension BidirectionalCollection
	where
	Self: RangeReplaceableCollection,
	Element: Equatable
{
	typealias Anchor = CollectionAnchor<Self>
	
	@inlinable func deleting(_ what: Anchor) -> Self {
		Self(what.left(from: self))
	}
	
	@inlinable func take(all what: Anchor) -> Self {
		Self(what.match(in: self))
	}
	
	@inlinable func matching(_ what: Anchor) -> Self {
		Self(what.match(in: self))
	}
	
	@inlinable func replacing(_ what: Anchor, with replacement: Self) -> Self where Self: Equatable {
		what.replacing(in: self, with: replacement)
	}
	
	// TODO: Implement
	/// string.take(all: .starting(with: .first, .dot), .before(.last, ")"))
}

