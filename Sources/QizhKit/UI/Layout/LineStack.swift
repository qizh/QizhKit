//
//  LineStack.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 04.06.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

fileprivate struct IdentifiedRect: Equatable {
	let id: String
	let rect: CGRect
	let measure: Measurement
	
	fileprivate init(_ id: String, _ rect: CGRect = .zero) {
		self.init(id, .fit, rect)
	}
	
	fileprivate init(_ id: String, _ measure: Measurement, _ rect: CGRect = .zero) {
		self.id = id
		self.rect = rect
		self.measure = measure
	}
	
	static  let zero: IdentifiedRect = .zero(.empty)
	static func zero(_ id: String) -> IdentifiedRect { .init(id, .zero) }
	var isZero: Bool { rect == .zero }
	
	enum Measurement {
		case fit
		case full
	}
}

fileprivate struct UnionRectPreferenceKey: PreferenceKey {
	public static var defaultValue: IdentifiedRect = .zero
	
	fileprivate static var  fitValues: [String: CGRect] = [:]
	fileprivate static var fullValues: [String: CGRect] = [:]
	
	public static func reduce(value: inout IdentifiedRect, nextValue: () -> IdentifiedRect) {
		let next = nextValue()
		if next.isZero {
			value = next
			 fitValues[next.id] = .zero
			fullValues[next.id] = .zero
		} else {
			let fitRect  = rect( .fit, for: next.id).union(next.rect)
			let fullRect = rect(.full, for: next.id).union(next.rect)
			switch next.measure {
			case  .fit:
				 fitValues[next.id] =  fitRect
				fullValues[next.id] = fullRect
				value = IdentifiedRect(next.id, fitRect)
			case .full:
				fullValues[next.id] = fullRect
				value = IdentifiedRect(next.id, fullRect)
			}
		}
	}
	
	fileprivate static func rect(_ measure: IdentifiedRect.Measurement, for id: String) -> CGRect {
		switch measure {
		case  .fit: return  fitValues[id, default: .zero]
		case .full: return fullValues[id, default: .zero]
		}
		
	}
}

@available(*, deprecated, message: "Use `Flock` instead", renamed: "Flock")
public struct LineStack<Input, Content>: View
	where
	Input: RandomAccessCollection,
	Input.Element: Hashable,
	Input: Hashable,
	Content: View
{
	public typealias Builder = (Input.Element) -> Content
	private typealias IDRect = UnionRectPreferenceKey
	
	private let id = UUID().uuidString
	private let data: Input
	private let build: Builder
	private let spacing: CGFloat
	
	@State private var size: CGSize = .zero
	
	public init(
		_ data: Input,
		spacing: CGFloat? = nil,
		@ViewBuilder build: @escaping Builder
	) {
		self.data = data
		self.build = build
		self.spacing = spacing ?? 16
	}
	
	private var  fitSize: CGSize { IDRect.rect( .fit, for: id).size }
	private var fullSize: CGSize { IDRect.rect(.full, for: id).size }

	private func fit(_ ir: IdentifiedRect) {
		let w = fitSize.width
		let h = fitSize.height
		size = CGSize(w.nextUp.rounded(.awayFromZero), h)
	}
	
	public var body: some View {
		GeometryReader(content: layout)
			.applyOnAppear { v in v
				.onPreferenceChange(IDRect.self, perform: fit)
				.size(size.nonZero, .leading)
				.fixedHeight()
			}
			.clipped()
		
			/* /// This also works
			.apply(when: size.isNotZero) { v in v
				.maxSize(size.nonZero, .leading)
				.ideal(size.nonZero, .leading)
				.fixedSize()
			}
			.clipped()
			*/
		
			/* /// Debug
			.overlayPreferenceValue(IDRect.self) { _ in
				HStack(spacing: 2) {
					/*
					IDRect.rect( .fit, for: self.id).labeledView(f: 0)
					IDRect.rect(.full, for: self.id).labeledView(f: 0)
					*/
					self .fitSize.labeledView(f: 0)
					self.fullSize.labeledView(f: 0)
				}
				.padding(.top, 20)
			}
			*/
	}
	
	private func layout(in space: GeometryProxy) -> some View {
		var width = CGFloat.zero
		let coords = CoordinateSpace.named(id)
		let end = data.count - 1
		let available = space.size.width
		
		return ZStack(alignment: .leading) {
			Color.almostClear
				.preference(key: IDRect.self, value: .zero(id))
				.hidden()
			ForEach(hashing: data) { offset, element in
				self.build(element)
				.alignmentGuide(.leading) { d in
					let result = width
					if offset == end { width = 0 }
					else { width -= d.width + self.spacing }
					return result
				}
				/* /// Debug
				.overlay(
					GeometryReader { element in
						[
							element.size.width,
							element.frame(in: coords).maxX,
							available.frame(in: coords).maxX,
							available.frame(in: coords).width
						]
						.map(Int.init)
						.labeledView()
						.scaleEffect(0.5)
						.transformPreference(IDRect.self) {
							let frame =   element.frame(in: coords)
							let space = available.frame(in: coords)
							$0 = IdentifiedRect(
								self.id,
								frame.maxX <= space.width
									? .fit
									: .full,
								frame
							)
						}
					}
				)
				*/
				.background(
					GeometryReader { element in
						Color.clear.transformPreference(IDRect.self) { idr in
							let rec = element.frame(in: coords)
							idr = .init(self.id, rec.maxX <= available ? .fit : .full, rec)
						}
					}
				)
			}
		}
		.coordinateSpace(name: id)
		.size(size.nonZero, .leading)
		.position(size.center)
	}
}

@available(iOS 14, *)
public extension HStack {
//	@inlinable
	static func Clipped<Input, Content>(
		_ data: Input,
		spacing: CGFloat = 16,
		@ViewBuilder build: @escaping Flock<Input, Content>.Builder
	) -> Flock<Input, Content>
		where
		Input: RandomAccessCollection,
		Input.Element: Hashable,
		Input: Hashable,
		Content: View
	{
		Flock(
			of: data,
			verticalSpacing: spacing,
			horizontalSpacing: spacing,
			build: build
		)
	}
}

#if DEBUG
fileprivate class Vocabulary {
	static let words = [
		"World",
		"Happiness",
		"No",
		"Enhancement",
		"Hash",
		"CGFloat",
		"Int",
		"Horizontal Alignment",
		"Padding",
		"Vertical Alignment",
		"View",
		"Spacing",
		"I",
		"Alpha",
		"Hi",
	]
	
	static func shuffled(seed: UInt64) -> [String] {
		var generator = SeededRandomGenerator(seed: seed)
		return words.shuffled(using: &generator)
	}
}

@available(iOS 14, *)
struct LineStack_Previews: PreviewProvider {
    static var previews: some View {
		Group {
/*
			VStack(alignment: .center, spacing: 4) {
				ForEach(hashing: [200, 180, 160, 140, 120, 100, 80, 70, 65, 64, 60, 50, 40, 20]) { _, width in
					LineStack(["Restaurants","Wine Tastings","Tastings","Classes","Local Food","Spa"].reversed().prefix(3), spacing: 4) { word in
						Text(word)
							.foregroundSystemBackground()
							.padding(.horizontal, 10)
							.padding(.vertical, 2)
							.backgroundColor(.blue)
							.cornerRadius(4)
							.lineLimit(1)
							.light(10)
					}
					.border.c9.w8.o4()
//					.width(width, .leading)
					.maxWidth(width, .center)
//					.border.c2.w8.o4()
				}
			}
			.padding()
			.systemBackground()
			.previewLayout(.fixed(width: 300, height: 300))
*/
			
/*
			LineStack(["Restaurants","Wine Tastings","Tastings","Classes","Local Food","Spa"].shuffled(seed: 4), spacing: 8) { word in
				Text(word)
					.regular(10)
					.fixedSize()
					.padding(4)
					.roundedBorder(.blue, radius: 6)
			}
			.border.c9.w4.o5()
			.width(330, .leading)
			.border.c2.w2.o2()
			.previewFitting()
			
			LineStack(Vocabulary.shuffled(seed: 3), spacing: 8) { word in
				Text(word)
					.regular(10)
					.fixedSize()
					.padding(4)
					.roundedBorder(.blue, radius: 6)
			}
//			.width(300, .leading)
//			.width(300, .center)
			.border.c9.w4.o5()
			.width(400, .trailing)
//			.maxWidth(.trailing)
			.border.c2.w2.o2()
			.previewFitting()
*/
			
			NavigationView {
				VStack(alignment: .center, spacing: 4) {
					Text("Top").regular(14)
					
					Flock(of: Vocabulary.shuffled(seed: 4), spacing: 4) { word in
						Text(word)
							.regular(8)
							.fixedSize()
							.padding(4)
							.padding(.horizontal, 2)
							.roundedBorder(.orange, radius: 6, weight: 2)
					}
//					.border.c9.w4.o5()

					Text("Bottom").semibold(9)
				}
				.width(300)
//				.border.c2.w2.o2()
			}
		}
    }
}
#endif
