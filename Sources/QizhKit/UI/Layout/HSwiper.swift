//
//  HSwiper.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.01.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
public struct HSwiper <Data, ID, Content>: View
	where
		Data: RandomAccessCollection,
		Data.Element: Identifiable,
		ID == Data.Element.ID,
		Content: View
{
	private let data: Data
	private let alignment: Alignment
	private let spacing: CGFloat
	@Binding private var selected: ID
	private let content: (Data.Element) -> Content
	
	@State private var dragOffset: CGFloat = .zero
	
	// MARK: Init
	
	public init(
		_ data: Data,
		alignment: Alignment = .center,
		spacing: CGFloat = .zero,
		selected: Binding<ID>,
		@ViewBuilder content: @escaping (Data.Element) -> Content
	) {
		self.data = data
		self.alignment = alignment
		self.spacing = spacing
		self._selected = selected
		self.content = content
	}

	public init <Source> (
		enumerating data: Source,
		alignment: Alignment = .center,
		spacing: CGFloat = .zero,
		selected: Binding<ID>,
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
			content: { content($0.offset, $0.element) }
		)
	}
	
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
	
	// MARK: Body
	
	public var body: some View {
		GeometryReader { geometry in
			LazyHStack(alignment: alignment.vertical, spacing: spacing) {
				ForEach(data) { item in
					content(item)
				}
				.size(geometry.size, alignment)
			}
			.offset(x: currentOffset(in: geometry.size))
//			.animation(.spring(), value: selected)
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

// MARK: Previews

#if DEBUG
@available(iOS 14.0, *)
struct HSwiper_Previews: PreviewProvider {
	struct Demo1: View {
		@State var page: Int = 0
		
		var body: some View {
			VStack {
				HSwiper(
					enumerating: ["Hello", "World"],
					alignment: .topLeading,
					spacing: 10,
					selected: $page
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
				Stepper(value: $page.animation(.spring()), in: 0 ... 1) {
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
