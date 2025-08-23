//
//  DebugViewBuilder.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.08.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import QizhMacroKit
import OrderedCollections

@resultBuilder
@MainActor
public struct DebugViewBuilder {
	public typealias DebuggableValue = Sendable & Hashable & CustomStringConvertible
	public typealias Element = OrderedDictionary<String, any DebuggableValue>.Element
	
	// MARK: Single
	
	public static func buildBlock(
		_ view: some View
	) -> some View {
		view
	}
	
	public static func buildBlock(
		_ element: Element
	) -> some View {
		element.value.labeledView(label: element.key)
	}
	
	public static func buildBlock<First: View, Second: View>(
		_ element: EitherView<First, Second>
	) -> some View {
		element
	}
	
	public static func buildBlock<T: CustomStringConvertible>(
		_ element: T
	) -> some View {
		element.labeledView()
	}
	
	/*
	public static func buildBlock<T>(
		_ element: T
	) -> some View {
		"\(element)".labeledView()
	}
	*/
	
	// MARK: Multiple
	
	@ViewBuilder
	public static func buildBlock<each P>(
		_ parameters: repeat each P
	) -> some View {
		MultipleViews(repeat buildBlock(each parameters))
		// ViewBuilder.buildBlock(repeat (buildBlock(each parameters)))
	}
	
	// MARK: Either
	
	public static func buildEither<First: View, Second: View>(
		first component: First
	) -> EitherView<First, Second> {
		.first(component)
	}
	
	public static func buildEither<First: View, Second: View>(
		second component: Second
	) -> EitherView<First, Second> {
		.second(component)
	}
}

extension DebugViewBuilder {
	public enum EitherView<First: View, Second: View>: View {
		case first(First)
		case second(Second)
		
		public var body: some View {
			switch self {
			case .first(let view): view
			case .second(let view): view
			}
		}
	}
	
	public struct MultipleViews: View {
		public let enumeratedViews: Array<(offset: Int, element: AnyView)>
		
		public init<each V: View>(
			_ views: repeat each V
		) {
			var tmp: [AnyView] = []
			for v in repeat each views {
				tmp.append(AnyView(erasing: v))
			}
			self.enumeratedViews = Array(tmp.enumerated())
		}
		
		public var body: some View {
			ForEach(enumeratedViews, id: \.offset) { item in
				item.element
			}
		}
	}
}


// MARK: - Debug View

public struct DebugView<Content: View>: View {
	fileprivate let content: Content
	
	public init(@DebugViewBuilder _ buildContent: () -> Content) {
		self.content = buildContent()
	}
	
	public var body: some View {
		VStack.LabeledViews {
			content
		}
	}
}

// MARK: - Previews

#if DEBUG
#Preview("Default") {
	let stringProperty = "Hello, World!"
	let optionalInt: Int? = 42
	let definedUInt: UInt = 100
	
	DebugView {
		Text(String("DebugViewBuilder"))
		#dictionarify(stringProperty)
		if let optionalInt {
			#dictionarify(definedUInt)
			#dictionarify(optionalInt)
		} else {
			#dictionarify(optionalInt)
			#dictionarify(definedUInt)
		}
	}
}
#endif
