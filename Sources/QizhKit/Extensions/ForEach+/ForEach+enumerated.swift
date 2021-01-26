//
//  ForEach+enumerated.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 13.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension ForEach where Content: View {
	/*
	public init <Source> (
		_ data: Source,
		@ViewBuilder content: @escaping (Int, Source.Element) -> Content
	) where
		Source: Collection,
		Source.Element: Identifiable,
		Data == [EnumeratedIdentifiableElement<Source>],
		ID == Source.Element.ID
	{
		self.init(data.enumeratedIdentifiableElements(), content: { content($0.offset, $0.element) })
	}
	*/
	
	public init <Source> (
		enumerating data: Source,
		@ViewBuilder content: @escaping (Int, Source.Element) -> Content
	) where
		Source: Collection,
		Data == [AnyEnumeratedElement<Source>],
		ID == AnyEnumeratedElement<Source>.ID
	{
		self.init(data.enumeratedElements(), content: { content($0.offset, $0.element) })
	}
	
	public init <Source> (
		hashing data: Source,
		@ViewBuilder content: @escaping (Int, Source.Element) -> Content
	) where
		Source: Collection,
		Source.Element: Hashable,
		Data == [EnumeratedHashableElement<Source>],
		ID == Source.Element
	{
		self.init(data.enumeratedHashableElements(), content: { content($0.offset, $0.element) })
	}
	
	public init <Source> (
		identifying data: Source,
		@ViewBuilder content: @escaping (Int, Source.Element) -> Content
	) where
		Source: Collection,
		Source.Element: Identifiable,
		Data == [EnumeratedIdentifiableElement<Source>],
		ID == Source.Element.ID
	{
		self.init(data.enumeratedIdentifiableElements(), content: { content($0.offset, $0.element) })
	}
}

public protocol EnumeratedElement: Identifiable {
	associatedtype Base: Collection
	
	typealias Element = Base.Element
	typealias Enumerated = EnumeratedSequence<Base>
	typealias Tuple = Enumerated.Element
	
	var offset: Int { get }
	var element: Element { get }
	var id: ID { get }
	
	init(_ enumerated: Tuple)
}

public extension EnumeratedElement {
	@inlinable var index: Int { offset }
	@inlinable var value: Element { element }
	@inlinable var item: Element { element }
	
	var tuple: Tuple {
		(offset, element)
	}
}

public struct AnyEnumeratedElement<Base: Collection>: EnumeratedElement {
	public let offset: Int
	public let element: Element
	
	public init(_ enumerated: Tuple) {
		offset = enumerated.offset
		element = enumerated.element
	}
	
	public var id: Int { offset }
}

public struct EnumeratedIdentifiableElement<Base: Collection>: EnumeratedElement where Base.Element: Identifiable {
	public let offset: Int
	public let element: Element
	
	public init(_ enumerated: Tuple) {
		offset = enumerated.offset
		element = enumerated.element
	}
	
	public var id: Element.ID { element.id }
}

public struct EnumeratedHashableElement<Base: Collection>: EnumeratedElement where Base.Element: Hashable {
	public let offset: Int
	public let element: Element
	
	public init(_ enumerated: Tuple) {
		offset = enumerated.offset
		element = enumerated.element
	}
	
	public var id: Element { element }
}

extension Collection {
	@inlinable func enumeratedElements() -> [AnyEnumeratedElement<Self>] {
		enumerated().map(AnyEnumeratedElement<Self>.init)
	}
}

extension Collection where Element: Identifiable {
	@inlinable func enumeratedIdentifiableElements() -> [EnumeratedIdentifiableElement<Self>] {
		enumerated().map(EnumeratedIdentifiableElement<Self>.init)
	}
}

extension Collection where Element: Hashable {
	@inlinable func enumeratedHashableElements() -> [EnumeratedHashableElement<Self>] {
		enumerated().map(EnumeratedHashableElement<Self>.init)
	}
}
