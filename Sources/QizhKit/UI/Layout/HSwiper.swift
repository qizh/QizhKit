//
//  HSwiper.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.01.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
public struct HSwiper <Data, ID, Content, IndicatorContent>: View
	where
		Data: RandomAccessCollection,
		Data.Element: Identifiable,
		ID == Data.Element.ID,
		Content: View,
		IndicatorContent: View
{
	public typealias IndicatorBuilder = (Int, Int, Int) -> IndicatorContent
	
	private let data: Data
	private let style: Style
	private let alignment: Alignment
	private let spacing: CGFloat
	private let isContentInteractive: Bool
	@Binding private var selected: ID
	private let content: (Data.Element) -> Content
	private let indicator: IndicatorBuilder
	
	@State private var dragOffset: CGFloat = .zero
	@State private var draggedPages: Int = .zero
	@State private var animationValue: UInt = .zero
	@State private var predictedOffset: CGFloat = .zero
	
	// MARK: Init
	
	public init(
		_ data: Data,
		style: Style = .full,
		isContentInteractive: Bool = false,
		alignment: Alignment = .center,
		spacing: CGFloat = .zero,
		selected: Binding<ID>,
		@ViewBuilder indicator: @escaping IndicatorBuilder,
		@ViewBuilder content: @escaping (Data.Element) -> Content
	) {
		self.data = data
		self.style = style
		self.isContentInteractive = isContentInteractive
		self.alignment = alignment
		self.spacing = spacing
		self._selected = selected
		self.content = content
		self.indicator = indicator
	}

	public init(
		_ data: Data,
		style: Style = .full,
		isContentInteractive: Bool = false,
		alignment: Alignment = .center,
		spacing: CGFloat = .zero,
		selected: Binding<ID>,
		@ViewBuilder content: @escaping (Data.Element) -> Content
	) where IndicatorContent == EmptyView {
		self.init(
			data,
			style: style,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: { _, _, _ in EmptyView() },
			content: content
		)
	}
	
	// MARK: Init Enumerating
	
	public init <Source> (
		enumerating data: Source,
		style: Style = .full,
		isContentInteractive: Bool = false,
		alignment: Alignment = .center,
		spacing: CGFloat = .zero,
		selected: Binding<ID>,
		@ViewBuilder indicator: @escaping IndicatorBuilder,
		@ViewBuilder content: @escaping (Int, Source.Element) -> Content
	) where
		Source: Collection,
		Data == [AnyEnumeratedElement<Source>]
	{
		self.init(
			data.enumeratedElements(),
			style: style,
			isContentInteractive: isContentInteractive,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: indicator,
			content: { content($0.offset, $0.element) }
		)
	}
	
	public init <Source> (
		enumerating data: Source,
		style: Style = .full,
		isContentInteractive: Bool = false,
		alignment: Alignment = .center,
		spacing: CGFloat = .zero,
		selected: Binding<ID>,
		@ViewBuilder content: @escaping (Int, Source.Element) -> Content
	) where
		Source: Collection,
		Data == [AnyEnumeratedElement<Source>],
		IndicatorContent == EmptyView
	{
		self.init(
			enumerating: data,
			style: style,
			isContentInteractive: isContentInteractive,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: { _, _, _ in EmptyView() },
			content: content
		)
	}
	
	// MARK: Init Hashing
	
	public init <Source> (
		hashing data: Source,
		style: Style = .full,
		isContentInteractive: Bool = false,
		alignment: Alignment = .center,
		spacing: CGFloat = .zero,
		selected: Binding<ID>,
		@ViewBuilder indicator: @escaping IndicatorBuilder,
		@ViewBuilder content: @escaping (Int, Source.Element) -> Content
	) where
		Source: Collection,
		Data == [EnumeratedHashableElement<Source>],
		ID == Source.Element
	{
		self.init(
			data.enumeratedHashableElements(),
			style: style,
			isContentInteractive: isContentInteractive,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: indicator,
			content: { content($0.offset, $0.element) }
		)
	}
	
	public init <Source> (
		hashing data: Source,
		style: Style = .full,
		isContentInteractive: Bool = false,
		alignment: Alignment = .center,
		spacing: CGFloat = .zero,
		selected: Binding<ID>,
		@ViewBuilder content: @escaping (Int, Source.Element) -> Content
	) where
		Source: Collection,
		Data == [EnumeratedHashableElement<Source>],
		ID == Source.Element,
		IndicatorContent == EmptyView
	{
		self.init(
			data.enumeratedHashableElements(),
			style: style,
			isContentInteractive: isContentInteractive,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: { _, _, _ in EmptyView() },
			content: { content($0.offset, $0.element) }
		)
	}
	
	// MARK: Init Identifying
	
	public init <Source> (
		identifying data: Source,
		style: Style = .full,
		isContentInteractive: Bool = false,
		alignment: Alignment = .center,
		spacing: CGFloat = .zero,
		selected: Binding<ID>,
		@ViewBuilder indicator: @escaping IndicatorBuilder,
		@ViewBuilder content: @escaping (Int, Source.Element) -> Content
	) where
		Source: Collection,
		Source.Element: Identifiable,
		Data == [EnumeratedIdentifiableElement<Source>],
		ID == Source.Element.ID
	{
		self.init(
			data.enumeratedIdentifiableElements(),
			style: style,
			isContentInteractive: isContentInteractive,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: indicator,
			content: { content($0.offset, $0.element) }
		)
	}
	
	public init <Source> (
		identifying data: Source,
		style: Style = .full,
		isContentInteractive: Bool = false,
		alignment: Alignment = .center,
		spacing: CGFloat = .zero,
		selected: Binding<ID>,
		@ViewBuilder content: @escaping (Int, Source.Element) -> Content
	) where
		Source: Collection,
		Source.Element: Identifiable,
		Data == [EnumeratedIdentifiableElement<Source>],
		ID == Source.Element.ID,
		IndicatorContent == EmptyView
	{
		self.init(
			data.enumeratedIdentifiableElements(),
			style: style,
			isContentInteractive: isContentInteractive,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: { _, _, _ in EmptyView() },
			content: { content($0.offset, $0.element) }
		)
	}
	
	// MARK: Style
	
	public enum Style {
		case full
		case carousel(_ width: CGFloat)
		
		public var isFull: Bool {
			switch self {
			case .full: return true
			default: return false
			}
		}
		
		public var isCarousel: Bool {
			switch self {
			case .carousel(_): return true
			default: return false
			}
		}
		
		public var carouselWidth: CGFloat? {
			switch self {
			case .full: return .none
			case .carousel(let width): return width
			}
		}
	}
	
	// MARK: Body
	
	public var body: some View {
		GeometryReader { fullGeometry in
			GeometryReader { geometry in
				ZStack(alignment: .topLeading) {
					let xOffset = currentOffset(in: geometry.size)
					LazyHStack(alignment: alignment.vertical, spacing: spacing) {
						switch style {
						case .full:
							ForEach(data) { item in
								content(item)
							}
							.size(geometry.size, alignment)
							.clipped()
						case .carousel(_):
							ForEach(identifying: data) { offset, item in
								content(item)
									.environment(\.centerDistance,
												  (geometry.size.width + spacing) * offset.cg + xOffset)
							}
							.size(geometry.size, alignment)
						}
					}
					.offset(x: xOffset)
					.allowsHitTesting(isContentInteractive)
					.zIndex(10)
					
					indicator(
						selectedPage,
						pageOffset(in: geometry.size),
						data.count
					)
					.size(geometry.size)
					.allowsHitTesting(false)
					.animation(.spring(), value: animationValue)
					.zIndex(20)
					
					/// Debug Calculations
					// debugCalculations(in: geometry.size).zIndex(30)
					
					Color.almostClear
						.padding(
							.leading,
							style.isCarousel
								? fullGeometry.frame(in: .global).minX
									- geometry.frame(in: .global).minX
								: 0
						)
						.size(fullGeometry.size)
						.allowsHitTesting(false)
						.zIndex(11)
				}
				.highPriorityGesture(dragGesture(card: geometry, full: fullGeometry))
				.animation(.spring(), value: dragOffset.isZero)
			}
			.width(style.carouselWidth, alignment)
			.maxWidth(alignment)
		}
		.clipped()
    }
	
	// MARK: Gesture
	
	private func dragGesture(
		card cardGeometry: GeometryProxy,
		full fullGeometry: GeometryProxy
	) -> some Gesture {
		let pageSize = cardGeometry.size.width + spacing
		return DragGesture(minimumDistance: 10)
			.onChanged { value in
				/// Worakroud to exit when edge swipe back gesture starts
				/// It moves frame to the edge of the screen: x = width
				guard fullGeometry.frame(in: .global).minX < fullGeometry.frame(in: .global).width
				else { return }
				/// Calculate offset between full frame and card frame
				let geometryDX = style.isCarousel
					? fullGeometry.frame(in: .global).minX
					- cardGeometry.frame(in: .global).minX
					: 0
				let tapFrame = fullGeometry.frame(in: .local)
					/// Offset to cover full frame
					.offset(x: geometryDX)
					/// Offset from the side of the screen
					/// to avoid glitches when using back swipe gesture
					.inset(leading: fullGeometry.frame(in: .global).minX == 0 ? 32 : 0)
				guard tapFrame.contains(value.startLocation) else { return }
				
				let dragOffsetSign = dragOffset.sign
				let offset = value.translation.width + draggedPages * pageSize
				let isEdgeSwiping =
					   selected == data.first?.id && offset.isPositive
					|| selected == data.last?.id  && offset.isNegative
				
				dragOffset = isEdgeSwiping ? offset.third : offset
				if dragOffset.magnitude > pageSize.half {
					let newDraggedPages = draggedPages + pagesCount(in: cardGeometry.size)
					let newSelected = currentSelected(in: cardGeometry.size)
					dragOffset = (newDraggedPages - draggedPages) * pageSize + dragOffset
					selected = newSelected
					draggedPages = newDraggedPages
				} else {
					predictedOffset = value.predictedEndTranslation.width
					if dragOffsetSign != dragOffset.sign {
						animationValue += 1
					}
				}
			}
			.onEnded { value in
				if draggedPages.isZero,
				   predictedOffset.magnitude > pageSize.half,
				   let newSelected = selected(with: -predictedOffset.sign.offset)
				{
					let newDraggedPages = draggedPages - predictedOffset.sign.offset
					dragOffset = (newDraggedPages - draggedPages) * pageSize + dragOffset
					selected = newSelected
					draggedPages = newDraggedPages
					execute(in: 10) {
						dragOffset = .zero
					}
				} else {
					dragOffset = .zero
				}
				predictedOffset = .zero
				draggedPages = .zero
			}
	}
	
	// MARK: Debug
	
	private func debugCalculations(in size: CGSize) -> some View {
		VStack.LabeledViews {
			pagesCount(in: size).labeledView(label: "swipe pages count")
			pageOffset(in: size).labeledView(label: "swipe page offset")
			draggedPages.labeledView(label: "dragged pages")
			dragOffset.signum.int.labeledView(label: "signum")
			dragOffset.labeledView(label: "offset", f: 0)
			predictedOffset.labeledView(label: "predicted", f: 0)
			selectedPage.labeledView(label: "selected page")
			animationValue.labeledView(label: "animation")
		}
	}
	
	// MARK: Shortcuts
	
	private func pageOffset(in size: CGSize) -> Int {
		-(dragOffset / (size.width + spacing))
			.rounded(.awayFromZero).int
	}
	
	private func pagesCount(in size: CGSize) -> Int {
		currentPage(in: size) - selectedPage
	}
	
	private func currentSelected(in size: CGSize) -> ID {
		data[currentIndex(in: size)].id
	}
	
	private func currentIndex(in size: CGSize) -> Data.Index {
		data.index(data.startIndex, offsetBy: currentPage(in: size))
	}
	
	private func currentPage(in size: CGSize) -> Int {
		let offset = -currentOffset(in: size)
		let stepWidth = size.width + spacing
		return (offset / stepWidth)
			.rounded(.toNearestOrAwayFromZero)
			.int
			.clippedFromZero(to: data.count - 1)
	}
	
	private func currentOffset(in size: CGSize) -> CGFloat {
		-selectedPage * (size.width + spacing) + dragOffset
	}
	
	private var selectedPage: Int {
		data.distance(from: data.startIndex, to: selectedIndex)
	}
	
	private var selectedIndex: Data.Index {
		data.firstIndex(id: selected) ?? data.startIndex
	}
	
	private func selectedIndex(with offset: Int) -> Data.Index {
		data.index(selectedIndex, offsetBy: offset)
	}
	
	private func page(at index: Data.Index) -> ID? {
		guard data.indices.contains(index) else { return .none }
		return data[index].id
	}
	
	private func selected(with offset: Int) -> ID? {
		page(at: selectedIndex(with: offset))
	}
}

// MARK: Floating Sign + offset

fileprivate extension FloatingPointSign {
	var offset: Int {
		switch self {
		case .minus: return -1
		case .plus: return 1
		}
	}
}

// MARK: Environment

public struct DistanceFromCenterEnvironmentKey: EnvironmentKey {
	public static var defaultValue: CGFloat = .zero
}

public extension EnvironmentValues {
	var centerDistance: CGFloat {
		get { self[DistanceFromCenterEnvironmentKey.self] }
		set { self[DistanceFromCenterEnvironmentKey.self] = newValue }
	}
}

// MARK: Indicator

public protocol HSwiperIndicatorShape {
	static var indicatorMaxWidth: CGFloat { get }
}
public enum HSwiperIndicatorShapeRectangle: HSwiperIndicatorShape {
	public static var indicatorMaxWidth: CGFloat { 20 }
}
public enum HSwiperIndicatorShapeCircle: HSwiperIndicatorShape {
	public static var indicatorMaxWidth: CGFloat { 4 }
}
public typealias HSwiperIndicatorRectangle = HSwiperIndicator<HSwiperIndicatorShapeRectangle>
public typealias HSwiperIndicatorCircle = HSwiperIndicator<HSwiperIndicatorShapeCircle>

public struct HSwiperIndicator <IndicatorShape: HSwiperIndicatorShape>: View {
	private let active: Int
	private let offset: Int
	private let total: Int
	
	private let spacing: CGFloat = 4
	
	public init(
		active: Int,
		offset: Int,
		total: Int
	) {
		self.active = active
		if offset >= 0 {
			self.offset = offset.clipped(from: 0, to: total - 1 - active)
		} else {
			self.offset = offset.clipped(from: -active, to: 0)
		}
		self.total = total
	}
	
	public var body: some View {
		HStack(spacing: spacing) {
			ForEach(0 ..< total, id: \.self) { index in
				RoundedCornersRectangle(2)
					.foregroundColor(.white(0.5))
					.height(4)
					.frame(minWidth: 4, maxWidth: IndicatorShape.indicatorMaxWidth)
					.overlay(
						RoundedCornersRectangle(2)
							.stroke(
								Color.black(
									index < activeLeading || index > activeTrailing
										? 0.1
										: 0
								),
								lineWidth: 0.5
							)
					)
					.apply(when: index == .zero) { content in
						content
							.overlay(
								GeometryReader { geometry in
									RoundedCornersRectangle(2)
										.foregroundColor(.white)
										.offset(x: activeLeading.cg * (geometry.size.width + spacing))
										.width(geometry.size.width + offset.magnitude.cg * (geometry.size.width + spacing))
								}
								.shadow(color: .black(0.3), radius: 1.5)
							)
					}
					.zIndex((total - index).double)
			}
		}
		
		/// Debug values
		// .add(.above, content: debugValues)
		
		.expand(.bottom)
		.padding()
	}
	
	private var activeLeading: Int {
		max(0, min(active, active + offset))
	}
	
	private var activeTrailing: Int {
		min(total - 1, max(active, active + offset))
	}
	
	private func debugValues() -> some View {
		VStack.LabeledViews {
			active.labeledView(label: "active")
			offset.labeledView(label: "offset")
			total.labeledView(label: "total")
		}
	}
}

// MARK: - Previews

#if DEBUG
fileprivate struct Demo1: View {
	struct Source: Identifiable, ExpressibleByStringLiteral {
		public let value: String
		public var id: String { value }
		
		init(value: String) {
			self.value = value
		}
		
		init(stringLiteral value: String) {
			self.init(value: value)
		}
	}
	
	private let isSelectable: Bool
	@State var page: Source.ID = .empty
	// @State var selected: Int = 0
	
	let data: [Source] =
		[
			"Hello",
			"World",
			"How",
			"is",
			"it",
			"going?",
		]
	
	public init(
		isSelectable: Bool,
		page: Source.ID? = .empty
	) {
		self.isSelectable = isSelectable
		self._page =? page
	}
	
	public var body: some View {
		VStack {
			HSwiper(
				data,
				isContentInteractive: isSelectable,
				spacing: 10,
				selected: $page,
				indicator: HSwiperIndicatorCircle.init
			) { source in
				VStack.LabeledViews {
					(self.data.firstIndex(id: source.id) ?? 0)
						.labeledView(label: "index")
					
					source.id.labeledView(label: "id")
					
					Text(String("Button"))
						.button()
						.buttonStyle(.borderedProminent)
						.padding(.top, 4)
				}
				.expand()
				.backgroundColor(
					[Color]([
						Color.white,
						Color.blue,
						Color.green,
						Color.orange,
						Color.pink,
						Color.purple,
						Color.red,
						Color.yellow,
					])[cycle: data.firstIndex(id: source.id) ?? 0]
				)
			}
			.height(180)
			.border.c1()
			
			Stepper(
				value: Binding(get: {
						data.firstIndex(id: page) ?? 0
					}, set: { index in
						withAnimation(.spring()) {
							page = (data[safe: index] ?? data[0]).id
						}
					}),
				in: 0 ... data.count - 1
			) {
				VStack.LabeledViews {
					(data.firstIndex(id: page) ?? 0).labeledView()
					page.labeledView()
				}
			}
		}
		.width(200)
	}
}

@available(iOS 17, *)
#Preview("Demo", traits: .sizeThatFitsLayout) {
	Demo1(
		isSelectable: false
	)
	.padding()
	.background(.systemBackground)
}

@available(iOS 17, *)
#Preview("Demo Selectable", traits: .sizeThatFitsLayout) {
	Demo1(
		isSelectable: true,
		page: "How"
	)
	.padding()
	.background(.systemBackground)
}
#endif
