//
//  ScrollView+onRelease.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 30.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import UIKit
import SwiftUI
import Introspect

public extension View {
	@inlinable func onScrollRelease(
		_ perform: @escaping ScrollViewEndDraggingDelegateModifier.Callback
	) -> some View {
		modifier(ScrollViewEndDraggingDelegateModifier(perform))
	}
	
	@inlinable func scrollOffset(_ offset: Binding<CGPoint>) -> some View {
		modifier(ScrollViewContentOffsetDelegateModifier(offset))
	}
	
	@inlinable @ViewBuilder func scrollOffset(
		_ offset: Binding<CGPoint>,
		delayed: Bool
	) -> some View {
		if delayed {
			onAppearModifier(ScrollViewContentOffsetDelegateModifier(offset))
		} else {
			modifier(ScrollViewContentOffsetDelegateModifier(offset))
		}
	}
}

// MARK: ScrollView + reader

public extension ScrollView {
	@inlinable
	static func reading <SpaceName: Hashable> (
		offset: Binding<CGPoint>,
		delayed: Bool = false,
		in coordinateSpaceName: SpaceName,
		_ axes: Axis.Set = .vertical,
		showsIndicators: Bool = true,
		@ViewBuilder content: () -> Content
	) -> some View {
		ScrollView(axes, showsIndicators: showsIndicators) {
			content()
		}
		.scrollOffset(offset, delayed: delayed)
	}
	
	/*
	static func reading <SpaceName: Hashable, OriginalContent: View> (
		offset: Binding<CGPoint>,
		delayed: Bool = false,
		in coordinateSpaceName: SpaceName,
		_ axes: Axis.Set = .vertical,
		showsIndicators: Bool = true,
		@ViewBuilder content: () -> OriginalContent
	) -> some View
		where Content == _ConditionalContent<AnyView, OriginalContent>
	{
		ScrollView(axes, showsIndicators: showsIndicators) {
			if #available(iOS 14.0, *) {
				content()
					.modifier(
						ScrollOffsetReader(
							offset: offset,
							in: coordinateSpaceName
						)
					)
			} else {
				content()
			}
		}
		.applyForIOS14 { view in
			view
				.coordinateSpace(name: coordinateSpaceName)
		} else: { view in
			view
				.scrollOffset(offset, delayed: delayed)
		}
	}
	*/
}

// MARK: Modifiers

public struct ScrollOffsetReader <SpaceName: Hashable>: ViewModifier {
	@Binding private var offset: CGPoint
	private let coordinateSpaceName: SpaceName
	
	public init(
		offset: Binding<CGPoint>,
		in coordinateSpaceName: SpaceName
	) {
		self._offset = offset
		self.coordinateSpaceName = coordinateSpaceName
	}
	
	public func body(content: Content) -> some View {
		content
			.background(.topLeading) {
				GeometryReader { geometry in
					Color.almostClear
						.transformPreference(OriginPreferenceKey.self) { value in
							value = geometry.frame(in: .named(coordinateSpaceName)).origin
						}
						.onPreferenceChange(OriginPreferenceKey.self) { value in
							offset = value
						}
				}
				.size0()
			}
	}
}

fileprivate struct OriginPreferenceKey: PreferenceKey {
	static var defaultValue: CGPoint = .zero
	static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
		value = nextValue()
	}
}

/*
public struct ScrollOffsetProvider: ViewModifier {
	private let coordinateSpace: Hashable
	@Binding private var offset: CGPoint
	
	public init(
		coordinateSpace: Hashable,
		offset: Binding<CGPoint>
	) {
		self.coordinateSpace = coordinateSpace
		self._offset = offset
	}
	
	public func body(content: Content) -> some View {
		content
			.background(
				GeometryReader { geometry in
					Color.clear
						.transformPreference(OriginPreferenceKey.self) {
							$0 = geometry.frame(in: .global).origin
						}
				}
			)
	}
}
*/

public struct ScrollViewEndDraggingDelegateModifier: ViewModifier {
	public typealias Callback = () -> Void
	public var onEndDragging: Callback
	
	@State private var delegate = IntrospectedScrollViewDelegate()
	
	public init(_ perform: @escaping Callback) {
		self.onEndDragging = perform
	}
	
	public func body(content: Content) -> some View {
		content
			.introspectScrollView { scrollView in
				if let delegateAssigned = scrollView.delegate as? IntrospectedScrollViewDelegate {
					self.delegate = delegateAssigned
				} else {
					scrollView.delegate = self.delegate
				}
				self.delegate.onEndDragging = self.onEndDragging
			}
	}
}

public struct ScrollViewContentOffsetDelegateModifier: ViewModifier {
	@State private var contentOffsetBase: CGPoint = .zero
	@Binding public var contentOffset: CGPoint
	
	@State private var delegate: IntrospectedScrollViewDelegate = .init()
	
	public init(_ contentOffset: Binding<CGPoint>) {
		self._contentOffset = contentOffset
	}
	
	public func body(content: Content) -> some View {
		content
			.introspectScrollView { scrollView in
				if let delegateAssigned = scrollView.delegate as? IntrospectedScrollViewDelegate {
					if self.delegate != delegateAssigned {
						self.delegate = delegateAssigned
					}
				} else {
					scrollView.delegate = self.delegate
				}
				
				if self.delegate.contentOffsetBase.y == CGFloat.zero.nextUp {
					self.delegate.contentOffsetBase = scrollView.contentOffset
				}
				self.delegate.contentOffset = self.$contentOffset
			}
	}
}

// MARK: Delegate

class IntrospectedScrollViewDelegate: NSObject, UIScrollViewDelegate {
	var contentOffsetBase: CGPoint = .init(x: .zero, y: CGFloat.zero.nextUp)
	
	var onEndDragging: ScrollViewEndDraggingDelegateModifier.Callback?
	var contentOffset: Binding<CGPoint>?
	
	override init() {
		super.init()
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		onEndDragging?()
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		contentOffset?.wrappedValue = (scrollView.contentOffset - contentOffsetBase).opposite
		/*
		let value = (scrollView.contentOffset - contentOffsetBase).opposite
		execute {
			self.contentOffset?.wrappedValue = value
		}
		*/
	}
	
	/*
	func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
		print("b: \(scrollView.adjustedContentInset.bottom)")
	}
	*/
}
