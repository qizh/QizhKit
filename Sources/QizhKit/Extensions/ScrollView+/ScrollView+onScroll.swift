//
//  ScrollView+onRelease.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 30.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

#if canImport(UIKit) && canImport(SwiftUIIntrospect)
import UIKit
import SwiftUIIntrospect

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
	@inlinable @MainActor static func reading <SpaceName: Hashable> (
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
}

// MARK: Modifiers

public struct ScrollViewEndDraggingDelegateModifier: ViewModifier {
	public typealias Callback = () -> Void
	public var onEndDragging: Callback
	
	@State private var delegate = IntrospectedScrollViewDelegate()
	
	public init(_ perform: @escaping Callback) {
		self.onEndDragging = perform
	}
	
	public func body(content: Content) -> some View {
		content
			.introspect(.scrollView, on: .iOS(.v16, .v17, .v18)) { scrollView in
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
			.introspect(.scrollView, on: .iOS(.v15, .v16, .v17)) { scrollView in
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
#endif

// MARK: Read Offset

public struct ScrollOffsetReader <SpaceName>: ViewModifier
	where SpaceName: Hashable,
		  SpaceName: Sendable
{
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
							Task { @MainActor in
								offset = value
							}
						}
				}
				.size0()
			}
	}
}

fileprivate struct OriginPreferenceKey: PreferenceKey {
	static let defaultValue: CGPoint = .zero
	static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
		value = nextValue()
	}
}

fileprivate struct ScrollOriginPreferenceKey: PreferenceKey {
	static let defaultValue: CGPoint = .zero
	static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
		value += nextValue()
	}
}

// MARK: Native Offset Reader

fileprivate struct ScrollOffsetStackPreferenceKey: PreferenceKey {
	static let defaultValue: [CGPoint] = .just(.zero)
	static func reduce(value: inout [CGPoint], nextValue: () -> [CGPoint]) {
		value.append(contentsOf: nextValue())
	}
}

extension ScrollView {
	@MainActor
	@inlinable public static func nativeReading(
		offset: Binding<CGPoint>,
		_ axes: Axis.Set = .vertical,
		showsIndicators: Bool = true,
		@ViewBuilder content: @escaping () -> Content
	) -> some View {
		OffsetReadingScrollView(
			axes,
			showsIndicators: showsIndicators,
			offset: offset,
			content: content
		)
	}
}

// MARK: - March 2025 approach

fileprivate struct PositionObservingView<Content: View>: View {
	var coordinateSpace: CoordinateSpace
	@Binding var position: CGPoint
	@ViewBuilder var content: () -> Content
	
	var body: some View {
		content()
			.background {
				GeometryReader { geometry in
					Color.clear.preference(
						key: PreferenceKey.self,
						value: geometry.frame(in: coordinateSpace).origin
					)
				}
			}
			.onPreferenceChange(PreferenceKey.self) { position in
				#if swift(>=6.1)
				/// Works in Xcode 16.3
				self.position = position
				#else
				/// Works in Xcode 16.2 and lags
				Task { @MainActor in
					self.position = position
				}
				#endif
			}
	}
	
	struct PreferenceKey: SwiftUI.PreferenceKey {
		static var defaultValue: CGPoint { .zero }

		static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
			/// We don’t actually need to implement any kind of reduce algorithm above,
			/// since we’ll only have a single view delivering values using that preference
			/// key within any given hierarchy (since our implementation is entirely
			/// contained within our PositionObservingView).
		}
	}
}

public struct OffsetReadingScrollView <Content>: View where Content: View {
	private let axes: Axis.Set
	private let showsIndicators: Bool
	@Binding private var offset: CGPoint
	private let contentBuilder: () -> Content
	
	@Namespace private var scrollNS
	
	public init(
		_ axes: Axis.Set = .vertical,
		showsIndicators: Bool = true,
		offset: Binding<CGPoint>,
		@ViewBuilder content contentBuilder: @escaping () -> Content
	) {
		self.axes = axes
		self.showsIndicators = showsIndicators
		self._offset = offset
		self.contentBuilder = contentBuilder
	}
	
	public var body: some View {
		ScrollView(axes, showsIndicators: showsIndicators) {
			PositionObservingView(
				coordinateSpace: .named(scrollNS),
				position: $offset,
				content: contentBuilder
			)
		}
		.coordinateSpace(name: scrollNS)
		
		/*
		ScrollView(axes, showsIndicators: showsIndicators) {
			content
				.background {
					GeometryReader { insideGeometry in
						Color.clear
							.preference(
								key: ScrollOriginPreferenceKey.self,
								value: insideGeometry.frame(in: .named(scrollNS)).topLeading
							)
					}
				}
		}
		.coordinateSpace(name: scrollNS)
		.onPreferenceChange(ScrollOriginPreferenceKey.self) { value in
			Task { @MainActor in
				offset = value
			}
		}
		*/
		
		/*
		GeometryReader { outside in
			ScrollView(axes, showsIndicators: showIndicators) {
				content
					.background(.topLeading) {
						GeometryReader { inside in
							Color.clear
								/*
								.preference(
									key: ScrollOffsetStackPreferenceKey.self,
									value: .just(offset(of: inside, in: outside))
								)
								*/
								.transformPreference(OriginPreferenceKey.self) { value in
									let offset = offset(of: inside, in: outside)
									execute {
										self.offset = offset
									}
									value = offset
								}
						}
					}
			}
			/*
			.onPreferenceChange(ScrollOffsetStackPreferenceKey.self) { value in
				offset = value.first ?? .zero
			}
			*/
			.onPreferenceChange(OriginPreferenceKey.self) { value in
				offset = value
			}
		}
		*/
	}
	
	/*
	private func offset(of inside: GeometryProxy, in outside: GeometryProxy) -> CGPoint {
		inside.frame(in: .global).topLeading - outside.frame(in: .global).topLeading
	}
	*/
}
