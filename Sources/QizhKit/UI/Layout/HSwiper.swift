//
//  HSwiper.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.01.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Swiper

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
	private let isLazy: Bool
	private let style: HSwiperStyle
	private let alignment: Alignment
	private let spacing: CGFloat
	private let isContentInteractive: Bool
	private let isPageClipped: Bool
	private let isStackClipped: Bool
	@Binding private var selected: ID
	private let content: (Data.Element) -> Content
	private let indicator: IndicatorBuilder
	
	@State private var dragOffset: CGFloat = .zero
	@State private var draggedPages: Int = .zero
	@State private var animationValue: UInt = .zero
	@State private var predictedOffset: CGFloat = .zero
	@State private var dragTimer: Timer? = .none
	
	// MARK: ┣ Init
	
	public init(
		_ data: Data,
		isLazy: Bool = true,
		style: HSwiperStyle = .full,
		isContentInteractive: Bool = false,
		isPageClipped: Bool = false,
		isStackClipped: Bool = true,
		alignment: Alignment = .center,
		spacing: CGFloat = .zero,
		selected: Binding<ID>,
		@ViewBuilder indicator: @escaping IndicatorBuilder,
		@ViewBuilder content: @escaping (Data.Element) -> Content
	) {
		self.data = data
		self.isLazy = isLazy
		self.style = style
		self.isContentInteractive = isContentInteractive
		self.isPageClipped = isPageClipped
		self.isStackClipped = isStackClipped
		self.alignment = alignment
		self.spacing = spacing
		self._selected = selected
		self.content = content
		self.indicator = indicator
	}
	
	public init(
		_ data: Data,
		isLazy: Bool = true,
		style: HSwiperStyle = .full,
		isContentInteractive: Bool = false,
		isPageClipped: Bool = false,
		isStackClipped: Bool = true,
		alignment: Alignment = .center,
		spacing: CGFloat = .zero,
		selected: Binding<ID>,
		@ViewBuilder content: @escaping (Data.Element) -> Content
	) where IndicatorContent == EmptyView {
		self.init(
			data,
			isLazy: isLazy,
			style: style,
			isContentInteractive: isContentInteractive,
			isPageClipped: isPageClipped,
			isStackClipped: isStackClipped,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: { _, _, _ in EmptyView() },
			content: content
		)
	}
	
	// MARK: ┣ Init Enumerating
	
	public init <Source> (
		enumerating data: Source,
		isLazy: Bool = true,
		style: HSwiperStyle = .full,
		isContentInteractive: Bool = false,
		isPageClipped: Bool = false,
		isStackClipped: Bool = true,
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
			isLazy: isLazy,
			style: style,
			isContentInteractive: isContentInteractive,
			isPageClipped: isPageClipped,
			isStackClipped: isStackClipped,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: indicator,
			content: { content($0.offset, $0.element) }
		)
	}
	
	public init <Source> (
		enumerating data: Source,
		isLazy: Bool = true,
		style: HSwiperStyle = .full,
		isContentInteractive: Bool = false,
		isPageClipped: Bool = false,
		isStackClipped: Bool = true,
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
			isLazy: isLazy,
			style: style,
			isContentInteractive: isContentInteractive,
			isPageClipped: isPageClipped,
			isStackClipped: isStackClipped,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: { _, _, _ in EmptyView() },
			content: content
		)
	}
	
	// MARK: ┣ Init Hashing
	
	public init <Source> (
		hashing data: Source,
		isLazy: Bool = true,
		style: HSwiperStyle = .full,
		isContentInteractive: Bool = false,
		isPageClipped: Bool = false,
		isStackClipped: Bool = true,
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
			isLazy: isLazy,
			style: style,
			isContentInteractive: isContentInteractive,
			isPageClipped: isPageClipped,
			isStackClipped: isStackClipped,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: indicator,
			content: { content($0.offset, $0.element) }
		)
	}
	
	public init <Source> (
		hashing data: Source,
		isLazy: Bool = true,
		style: HSwiperStyle = .full,
		isContentInteractive: Bool = false,
		isPageClipped: Bool = false,
		isStackClipped: Bool = true,
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
			isLazy: isLazy,
			style: style,
			isContentInteractive: isContentInteractive,
			isPageClipped: isPageClipped,
			isStackClipped: isStackClipped,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: { _, _, _ in EmptyView() },
			content: { content($0.offset, $0.element) }
		)
	}
	
	// MARK: ┣ Init Identifying
	
	public init <Source> (
		identifying data: Source,
		isLazy: Bool = true,
		style: HSwiperStyle = .full,
		isContentInteractive: Bool = false,
		isPageClipped: Bool = false,
		isStackClipped: Bool = true,
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
			isLazy: isLazy,
			style: style,
			isContentInteractive: isContentInteractive,
			isPageClipped: isPageClipped,
			isStackClipped: isStackClipped,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: indicator,
			content: { content($0.offset, $0.element) }
		)
	}
	
	public init <Source> (
		identifying data: Source,
		isLazy: Bool = true,
		style: HSwiperStyle = .full,
		isContentInteractive: Bool = false,
		isPageClipped: Bool = false,
		isStackClipped: Bool = true,
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
			isLazy: isLazy,
			style: style,
			isContentInteractive: isContentInteractive,
			isPageClipped: isPageClipped,
			isStackClipped: isStackClipped,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: { _, _, _ in EmptyView() },
			content: { content($0.offset, $0.element) }
		)
	}
	
	// MARK: ┣ Body
	
	public var body: some View {
		GeometryReader { fullGeometry in
			GeometryReader { geometry in
				ZStack(alignment: .topLeading) {
					let xOffset = currentOffset(in: geometry.size)
					
					Group {
						if isLazy {
							LazyHStack(alignment: alignment.vertical, spacing: spacing) {
								switch style {
								case .full:
									ForEach(data) { item in
										content(item)
									}
									.size(geometry.size, alignment)
									.apply(when: isPageClipped) { page in
										page.clipped()
									}
								case .carousel(_):
									ForEach(identifying: data) { offset, item in
										content(item)
											.environment(\.centerDistance,
														  (geometry.size.width + spacing) * offset.cg + xOffset)
									}
									.size(geometry.size, alignment)
								}
							}
						} else {
							HStack(alignment: alignment.vertical, spacing: spacing) {
								switch style {
								case .full:
									ForEach(data) { item in
										content(item)
									}
									.size(geometry.size, alignment)
									.apply(when: isPageClipped) { page in
										page.clipped()
									}
								case .carousel(_):
									ForEach(identifying: data) { offset, item in
										content(item)
											.environment(\.centerDistance,
														  (geometry.size.width + spacing) * offset.cg + xOffset)
									}
									.size(geometry.size, alignment)
								}
							}
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
						.apply { view in
							if isContentInteractive {
								view
									.allowsHitTesting(false)
							} else {
								view.gesture(
									dragGesture(card: geometry, full: fullGeometry)
								)
							}
						}
						.zIndex(11)
				}
				.apply(when: isContentInteractive) { stack in
					stack.highPriorityGesture(
						dragGesture(card: geometry, full: fullGeometry)
					)
				}
				.animation(.spring(), value: dragOffset.isZero)
			}
			.width(style.carouselWidth, alignment)
			.maxWidth(alignment)
		}
		.apply(when: isStackClipped) { stack in
			stack.clipped()
		}
    }
	
	// MARK: ┣ Gesture
	
	private func dragGesture(
		card cardGeometry: GeometryProxy,
		full fullGeometry: GeometryProxy
	) -> some Gesture {
		DragGesture(
			minimumDistance: 16
		)
		.onChanged { value in
			onDragGestureChange(
				with: value,
				card: cardGeometry,
				full: fullGeometry,
				pageSize: cardGeometry.size.width + spacing
			)
		}
		.onEnded { value in
			onDragGestureEnded(
				with: value,
				pageSize: cardGeometry.size.width + spacing
			)
		}
	}
	
	// MARK: ┃┣ Change
	
	fileprivate func onDragGestureChange(
		with value: DragGesture.Value,
		card cardGeometry: GeometryProxy,
		full fullGeometry: GeometryProxy,
		pageSize: CGFloat
	) {
		/// Worakroud to exit when edge swipe back gesture starts
		/// It moves frame to the edge of the screen: x = width
		guard fullGeometry.frame(in: .global).minX 
			< fullGeometry.frame(in: .global).width
		else {
			// print("exit on swipe back")
			return
		}
		
		/// Calculate offset between full frame and card frame
		let geometryDX =
			switch style {
			case .full:
				CGFloat.zero
			case .carousel:
				  fullGeometry.frame(in: .global).minX
				- cardGeometry.frame(in: .global).minX
			}
		
		let tapFrame = fullGeometry.frame(in: .local)
			/// Offset to cover full frame
			.offset(x: geometryDX)
			/// Offset from the side of the screen
			/// to avoid glitches when using back swipe gesture
			.inset(leading: fullGeometry.frame(in: .global).minX == 0 ? 32 : 0)
		
		guard tapFrame.contains(value.startLocation) else {
			// print("exit tap frame")
			return
		}
		
		// print("drag {w: \(value.translation.width, f: 0), h: \(value.translation.height, f: 0)}")
		let dragOffsetSign = dragOffset.sign
		let offset = value.translation.width + draggedPages * pageSize
		
		/// Is dragging further than the edge
		let isEdgeSwiping =
			   selected == data.first?.id && offset.isPositive
			|| selected == data.last?.id  && offset.isNegative
		
		dragOffset = if isEdgeSwiping {
			/// Drag resiting effect
			offset.third
		} else {
			offset
		}
		
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
		
		timerContinue(lastDragValue: value, pageSize: pageSize)
	}
	
	// MARK: ┃┗ End
	
	fileprivate func onDragGestureEnded(
		with value: DragGesture.Value,
		pageSize: CGFloat
	) {
		// print("on ended")
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
		
		timerEnd()
	}
	
	// MARK: Drag Timer
	
	private func timerEnd() {
		dragTimer?.invalidate()
		dragTimer = .none
	}
	
	private func timerContinue(
		lastDragValue value: DragGesture.Value,
		pageSize: CGFloat
	) {
		dragTimer?.invalidate()
		dragTimer = .scheduledTimer(
			withTimeInterval: 2, /// Two seconds
			repeats: false
		) { timer in
			onDragGestureEnded(with: value, pageSize: pageSize)
		}
	}
	
	// MARK: ┣ Debug
	
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
	
	// MARK: ┗ Shortcuts
	
	private func pageOffset(in size: CGSize) -> Int {
		if size.width + spacing == .zero {
			.zero
		} else {
			-(dragOffset / (size.width + spacing))
				.rounded(.awayFromZero).int
		}
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

// MARK: - Style

public enum HSwiperStyle {
	case full
	case carousel(_ width: CGFloat)
	
	fileprivate var isFull: Bool {
		switch self {
		case .full: return true
		default: return false
		}
	}
	
	fileprivate var isCarousel: Bool {
		switch self {
		case .carousel(_): return true
		default: return false
		}
	}
	
	fileprivate var carouselWidth: CGFloat? {
		switch self {
		case .full: return .none
		case .carousel(let width): return width
		}
	}
}

// MARK: - Floating Sign + offset

fileprivate extension FloatingPointSign {
	var offset: Int {
		switch self {
		case .minus: return -1
		case .plus: return 1
		}
	}
}

// MARK: - Environment

public struct DistanceFromCenterEnvironmentKey: EnvironmentKey {
	public static var defaultValue: CGFloat = .zero
}

public extension EnvironmentValues {
	var centerDistance: CGFloat {
		get { self[DistanceFromCenterEnvironmentKey.self] }
		set { self[DistanceFromCenterEnvironmentKey.self] = newValue }
	}
}

// MARK: - Indicator inputs

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

public enum HSwiperIndicatorStyle: Hashable {
	case over
	case under
}

extension HSwiperIndicatorStyle {
	fileprivate var foregroundColor: Color {
		switch self {
		case .over: .white
		case .under: .label
		}
	}
	
	fileprivate func inactiveOpacity(for colorScheme: ColorScheme) -> Double {
		switch self {
		case .over: 0.5
		case .under:
			if colorScheme.isDark {
				0.5
			} else {
				0.2
			}
		}
	}
}

// MARK: - Indicator

public struct HSwiperIndicator <IndicatorShape: HSwiperIndicatorShape>: View {
	private let active: Int
	private let offset: Int
	private let total: Int
	private let style: HSwiperIndicatorStyle
	
	private let spacing: CGFloat = 4
	
	@Environment(\.colorScheme) private var colorScheme
	
	public init(
		active: Int,
		offset: Int,
		total: Int,
		style: HSwiperIndicatorStyle
	) {
		self.active = active
		if offset >= 0 {
			self.offset = offset.clipped(from: 0, to: total - 1 - active)
		} else {
			self.offset = offset.clipped(from: -active, to: 0)
		}
		self.total = total
		self.style = style
	}
	
	@inlinable public init(
		active: Int,
		offset: Int,
		total: Int
	) {
		self.init(
			active: active,
			offset: offset,
			total: total,
			style: .over
		)
	}
	
	// MARK: ┣ Body
	
	public var body: some View {
		HStack(spacing: spacing) {
			ForEach(0 ..< total, id: \.self) { index in
				RoundedCornersRectangle(2)
					.foregroundColor(style.foregroundColor.opacity(style.inactiveOpacity(for: colorScheme)))
					.height(4)
					.frame(minWidth: 4, maxWidth: IndicatorShape.indicatorMaxWidth)
					.overlay {
						if style == .over {
							RoundedCornersRectangle(2)
								.stroke(
									Color.black(
										index < activeLeading || index > activeTrailing
										? 0.1
										: 0
									),
									lineWidth: 0.5
								)
						}
					}
					.apply(when: index == .zero) { content in
						content
							.overlay(
								GeometryReader { geometry in
									RoundedCornersRectangle(2)
										.foregroundColor(style.foregroundColor)
										.offset(x: activeLeading.cg * (geometry.size.width + spacing))
										.width(geometry.size.width + offset.magnitude.cg * (geometry.size.width + spacing))
								}
								.apply(when: style == .over) { view in
									view.shadow(color: .black(0.3), radius: 1.5)
								}
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
	
	// MARK: ┣ Shortcuts
	
	private var activeLeading: Int {
		max(0, min(active, active + offset))
	}
	
	private var activeTrailing: Int {
		min(total - 1, max(active, active + offset))
	}
	
	// MARK: ┗ Debug
	
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

fileprivate var previewWords: [TestSwiper.Item] {
	[
		"Hello",
		"World",
		"How",
		"is",
		"it",
		"going?",
	]
}

// MARK: ┣ Test view

fileprivate struct TestSwiper: View {
	private let style: HSwiperStyle
	private let isContentInteractive: Bool
	private let isLazy: Bool
	@State var page: Item.ID = .empty
	// @State var selected: Int = 0
	
	public init(
		style: HSwiperStyle = .full,
		isContentInteractive: Bool,
		isLazy: Bool = true,
		page: Item.ID? = .empty
	) {
		self.style = style
		self.isContentInteractive = isContentInteractive
		self.isLazy = isLazy
		self._page =? page ?? previewWords.first?.id
	}
	
	public var body: some View {
		VStack {
			HSwiper(
				previewWords,
				style: style,
				isContentInteractive: isContentInteractive,
				spacing: 10,
				selected: $page
			) { active, offset, total in
				HSwiperIndicatorCircle(
					active: active,
					offset: offset,
					total: total,
					style: .over
					// style: .under
				)
			} content: { source in
				Card(item: source, isScalable: style.isCarousel)
			}
			.height(Card.size.height)
			.border.c1()
			
			Stepper(
				value: .init {
					previewWords.firstIndex(id: page) ?? 0
				} set: { index in
					withAnimation {
						page = (previewWords[safe: index] ?? previewWords[0]).id
					}
				},
				in: 0 ... previewWords.count - 1
			) {
				VStack.LabeledViews {
					(previewWords.firstIndex(id: page) ?? 0).labeledView()
					page.labeledView()
				}
			}
			.padding(.horizontal, style.isFull ? .zero : .none)
		}
		.width(style.isFull ? Card.size.width : .none)
	}
}

// MARK: ┣ Card

extension TestSwiper {
	struct Card: View {
		static let size: CGSize = [200, 180]
		
		var item: Item
		var isScalable: Bool
		
		@Environment(\.centerDistance) private var distance
		
		var body: some View {
			VStack.LabeledViews {
				(previewWords.firstIndex(id: item.id) ?? 0)
					.labeledView(label: "index")
				
				item.id.labeledView(label: "id")
				
				Text(String("Button"))
					.button {
						print("button tap")
					}
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
				])[cycle: previewWords.firstIndex(id: item.id) ?? 0]
			)
			
			.apply(when: isScalable) { card in
				card
					.offset(
						x: (
							max(distance.absolute - Self.size.width, 0).half
							- max(distance.absolute - Self.size.width, 0)
								.map(from: [0, Self.size.width], to: [0, 16])
						) * (
							distance.isPositive
							? .minusOne
							: .one
						)
					)
					.scaleEffect(
						1 - min(distance.absolute, Self.size.width)
							.map(from: [0, Self.size.width], to: [0, 0.3]),
						anchor: distance.isPositive
						? .leading
						: .trailing
					)
			}
		}
	}
}

// MARK: ┣ Data Item

extension TestSwiper {
	struct Item: Identifiable, ExpressibleByStringLiteral {
		let value: String
		var id: String { value }
		
		init(value: String) {
			self.value = value
		}
		
		init(stringLiteral value: String) {
			self.init(value: value)
		}
	}
}

// MARK: ┣ S

#Preview("Default") {
	TestSwiper(
		isContentInteractive: false
	)
	.padding()
	.background(.systemBackground)
}

#Preview("Carousel") {
	TestSwiper(
		style: .carousel(200),
		isContentInteractive: false,
		isLazy: false
	)
	/*
	.padding()
	.border.c4()
	.background(.systemBackground)
	*/
}

#Preview("Interactive") {
	TestSwiper(
		isContentInteractive: true,
		isLazy: false,
		page: "How"
	)
	.padding()
	.background(.systemBackground)
}

#Preview("Interactive | in scroll") {
	ScrollView(.vertical) {
		TestSwiper(
			isContentInteractive: true,
			isLazy: true,
			page: "How"
		)
		.padding()
		.maxWidth(.center)
		.padding(.top, 300)
		.padding(.bottom, 600)
	}
	.background(.systemBackground)
}

#endif
