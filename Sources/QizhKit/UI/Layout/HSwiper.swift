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
	private let alignment: Alignment
	private let spacing: CGFloat
	@Binding private var selected: ID
	private let content: (Data.Element) -> Content
	private let indicator: IndicatorBuilder
	
	@State private var dragOffset: CGFloat = .zero
	
	// MARK: Init
	
	public init(
		_ data: Data,
		alignment: Alignment = .center,
		spacing: CGFloat = .zero,
		selected: Binding<ID>,
		@ViewBuilder indicator: @escaping IndicatorBuilder,
		@ViewBuilder content: @escaping (Data.Element) -> Content
	) {
		self.data = data
		self.alignment = alignment
		self.spacing = spacing
		self._selected = selected
		self.content = content
		self.indicator = indicator
	}

	public init(
		_ data: Data,
		alignment: Alignment = .center,
		spacing: CGFloat = .zero,
		selected: Binding<ID>,
		@ViewBuilder content: @escaping (Data.Element) -> Content
	) where IndicatorContent == EmptyView {
		self.init(
			data,
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: { _, _, _ in EmptyView() },
			content: content
		)
	}
	
	public init <Source> (
		enumerating data: Source,
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
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: indicator,
			content: { content($0.offset, $0.element) }
		)
	}
	
	public init <Source> (
		enumerating data: Source,
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
			alignment: alignment,
			spacing: spacing,
			selected: selected,
			indicator: { _, _, _ in EmptyView() },
			content: content
		)
	}
	
	/*
	public init <Source> (
		hashing data: Source,
		selected: Binding<ID>,
		@ViewBuilder content: @escaping (Int, Source.Element) -> Content
	) where
		Source: Collection,
		Source.Element: Hashable,
		Data == [EnumeratedHashableElement<Source>],
		ID == Source.Element
	{
		self.init(
			data.enumeratedHashableElements(),
			selected: selected,
			content: { content($0.offset, $0.element) }
		)
	}
	
	public init <Source> (
		identifying data: Source,
		selected: Binding<ID>,
		@ViewBuilder content: @escaping (Int, Source.Element) -> Content
	) where
		Source: Collection,
		Source.Element: Identifiable,
		Data == [EnumeratedIdentifiableElement<Source>],
		ID == Source.Element.ID
	{
		self.init(
			data.enumeratedIdentifiableElements(),
			selected: selected,
			content: { content($0.offset, $0.element) }
		)
	}
	*/
	
	// MARK: Body
	
	public var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .topLeading) {
				LazyHStack(alignment: alignment.vertical, spacing: spacing) {
					ForEach(data) { item in
						content(item)
					}
					.size(geometry.size, alignment)
				}
				.offset(x: currentOffset(in: geometry.size))
				.zIndex(10)
				
				indicator(
					selectedPage,
					pageOffset(in: geometry.size),
					data.count
				)
				.animation(.spring(), value: pageOffset(in: geometry.size))
				.size(geometry.size)
				.zIndex(20)
			}
			.backgroundColor(.almostClear)
			.gesture(
				DragGesture(minimumDistance: 5)
					.onChanged { value in
						let offset = value.translation.width
						let isEdgeSwiping =
							   selected == data.first?.id && offset.isPositive
							|| selected == data.last?.id  && offset.isNegative
						
						dragOffset = isEdgeSwiping ? offset.third : offset
					}
					.onEnded { value in
						let pageSize = geometry.size.width + spacing
						let swipePagesCount = pagesCount(in: geometry.size)
						selected = currentSelected(in: geometry.size)
						dragOffset = swipePagesCount * pageSize + dragOffset
						
						withAnimation(.spring()) {
							dragOffset = .zero
						}
					}
			)
		}
		.clipped()
    }
	
	/*
	private func activePages(in size: CGSize) -> [Int] {
		dragOffset.isZero
			? [selectedPage]
			: [selectedPage, currentPage(in: size)].sorted()
	}
	*/
	
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
}

// MARK: Indicator

public struct HSwiperIndicator: View {
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
		self.offset = offset
		self.total = total
	}
	
	public var body: some View {
		HStack(spacing: spacing) {
			ForEach(0 ..< total) { index in
				RoundedCornersRectangle(2)
					.foregroundColor(.white(0.5))
					.height(4)
					.frame(minWidth: 4, maxWidth: 20)
					.apply(when: index == .zero) { content in
						content
							.overlay(
								GeometryReader { geometry in
									RoundedCornersRectangle(2)
										.foregroundColor(.white)
										.offset(x: activeLeading.cg * (geometry.size.width + spacing))
										.width(geometry.size.width + offset.magnitude.cg * (geometry.size.width + spacing))
//										.animation(.spring(), value: offset)
//										.transition(.identity)
								}
							)
//							.alignmentGuide(.leadingSide) { _ in .zero }
					}
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
	
	private func debugValues() -> some View {
		VStack.LabeledViews {
			active.labeledView(label: "active")
			offset.labeledView(label: "offset")
			total.labeledView(label: "total")
		}
	}
}

// MARK: Previews

#if DEBUG
@available(iOS 14.0, *)
struct HSwiper_Previews: PreviewProvider {
	struct Demo1: View {
		@State var page: Int = 0
		
		var data: [String] {
			[
				"Hello",
				"World",
				"How",
				"is",
				"it",
				"going?",
			]
		}
		
		var body: some View {
			VStack {
				HSwiper(
					enumerating: data,
					alignment: .topLeading,
					spacing: 10,
					selected: $page,
					indicator: HSwiperIndicator.init
				) { offset, title in
					VStack.LabeledViews {
						title.labeledView(label: "title")
						offset.labeledView(label: "offset")
					}
					.expand()
					.backgroundColor(
						offset.isZero ? .pink : .blue
					)
				}
				.size(200, 150)
				.border.c1()
				
				page.labeledView(label: "page")
				Stepper(value: $page.animation(.spring()), in: 0 ... data.count - 1) {
					EmptyView()
				}
				.fixedSize()
			}
		}
	}
	
    static var previews: some View {
		Demo1()
			.previewFitting()
    }
}
#endif
