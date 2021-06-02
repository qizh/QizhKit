//
//  Flock.swift
//  Bespokely
//
//  Created by Serhii Shevchenko on 25.12.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public enum FlockHeight: EasyCaseComparable {
	case fit
	case expand
}

public enum FlockLines: Equatable, EasyCaseComparable {
	case one
	case some(_ amount: Int)
	case unlimited
	
	var amount: Int {
		switch self {
		case .one: return .one
		case .some(let amount): return amount
		case .unlimited: return .max
		}
	}
}

// TODO: Implement the following
#warning("TODO: Implement Flock @functionBuilder init option")

@available(iOS 14, *)
public struct Flock <Input, Content>: View
	where
		Input: RandomAccessCollection,
		Input.Element: Hashable,
		Input: Hashable,
		Content: View
{
	
	public typealias Builder = (Input.Element) -> Content
	
	private let data: [Input.Element]
	private let build: Builder
	private let height: FlockHeight
	private let alignment: Alignment
	private let verticalSpacing: CGFloat
	private let horizontalSpacing: CGFloat
	private let linesLimit: FlockLines
	private let animation: Animation?
	private let debug: Bool
	
	@StateObject private var layout: FlockLayout
	
	public init(
		of data: Input,
		height: FlockHeight = .fit,
		alignment: Alignment = .topLeading,
		verticalSpacing: CGFloat = 4,
		horizontalSpacing: CGFloat = 4,
		linesLimit: FlockLines = .unlimited,
		animation: Animation? = .spring(),
		debug: Bool = false,
		@ViewBuilder build: @escaping Builder
	) {
		let uniqueElements = data.removingHashableDuplicates()
		
		self.data = uniqueElements
		self.build = build
		self.height = height
		self.alignment = alignment
		self.verticalSpacing = verticalSpacing
		self.horizontalSpacing = horizontalSpacing
		self.linesLimit = linesLimit
		self.animation = animation
		self.debug = debug
		
		self._layout = .init(
			wrappedValue: FlockLayout(
				count: uniqueElements.count,
				heightAttitude: height,
				alignment: alignment,
				verticalSpacing: verticalSpacing,
				horizontalSpacing: horizontalSpacing,
				linesLimit: linesLimit,
				debug: debug
			)
		)
	}
	
	public init(
		of data: Input,
		height: FlockHeight = .fit,
		alignment: Alignment = .topLeading,
		spacing: CGFloat,
		linesLimit: FlockLines = .unlimited,
		animation: Animation? = .spring(),
		debug: Bool = false,
		@ViewBuilder build: @escaping Builder
	) {
		self.init(
			of: data,
			height: height,
			alignment: alignment,
			verticalSpacing: spacing,
			horizontalSpacing: spacing,
			linesLimit: linesLimit,
			animation: animation,
			debug: debug,
			build: build
		)
	}
	
	public var body: some View {
		ZStack(alignment: .topLeading) {
			ForEach(hashing: data) { index, item in
				build(item)
					.background(
						GeometryReader { geometry in
							Color.almostClear
//								.preference(key: SizePreferenceKey.self, value: geometry.size)
								.transformPreference(SizePreferenceKey.self) { $0 = geometry.size }
								.onPreferenceChange(SizePreferenceKey.self) { itemSize in
									layout.save(size: itemSize, at: index)
								}
						}
					)
					.apply(mapping: layout.frames[safe: index]) { element, frame in
						element
							.size(frame.size.nonZero, .topLeading)
							.position(frame.center)
//							.offset(frame.origin.size)
							.animation(animation, value: frame)
					}
					.hidden(index > layout.lastVisibleIndex)
					.id(item)
			}
			.zIndex(20)
//			.id(data)
			
			GeometryReader { geometry in
				Color.almostClear
					.transformPreference(SizePreferenceKey.self) { $0 = geometry.size }
					.onPreferenceChange(SizePreferenceKey.self) { space in
						layout.fit(in: space)
					}
			}
			.zIndex(10)
			.layoutPriority(1)
		}
		.apply(when: layout.lines.isNotEmpty) { content in
			switch height {
			case .fit:
				content
					.frame(
						minWidth: layout.minWidth,
						idealWidth: layout.width,
						maxWidth: .infinity,
						minHeight: layout.minHeight,
						idealHeight: layout.height,
						maxHeight: layout.height,
						alignment: .topLeading
					)
			case .expand:
				content
					.frame(
						width: layout.width,
						height: layout.height,
						alignment: .topLeading
					)
			}
		}
		.clipped()
		.apply(when: debug) { content in
			content
				.border.c4()
				.overlay(.topTrailing) {
					VStack.LabeledViews {
						layout.space.labeledView(label: "space", f: 2)
						CGSize(layout.width, layout.height).labeledView(label: "size", f: 2)
						CGSize(layout.minWidth, layout.minHeight).labeledView(label: "min size", f: 2)
						layout.sizes.labeledViews(label: "sizes")
						layout.frames.labeledViews(label: "frames")
						layout.lines.labeledViews(label: "lines")
						layout.debugStates.labeledViews(label: "debug")
					}
					.fixedSize()
					.offset(x: 200)
				}
		}
		.apply(when: data.isEmpty) { _ in
			Pixel()
		}
		.onChange(of: data) { data in
			layout.reset(data.count)
		}
    }
}

// MARK: Layout

fileprivate final class FlockLayout: ObservableObject {
	private var count: Int
	private let heightAttitude: FlockHeight
	private let alignment: Alignment
	private let verticalSpacing: CGFloat
	private let horizontalSpacing: CGFloat
	private let linesLimit: FlockLines
	private let debug: Bool
	
	var debugStates: [String]
	var sizes: [CGSize]
	var space: CGRect = .zero
	@Published var lines: [Line] = .empty
	@Published var frames: [CGRect]
	@Published var lastVisibleIndex: Int = .max
	@Published var width: CGFloat
	@Published var minWidth: CGFloat = .zero
	@Published var height: CGFloat
	@Published var minHeight: CGFloat = .zero
	
	struct Line: CustomStringConvertible {
		let range: ClosedRange<Int>
		let width: CGFloat
		let height: CGFloat
		
		init(
			for range: ClosedRange<Int>,
			width: CGFloat,
			height: CGFloat
		) {
			self.range = range
			self.width = width
			self.height = height
		}
		
		init(
			for range: Range<Int>,
			width: CGFloat,
			height: CGFloat
		) {
			self.range = range.lowerBound ... max(range.lowerBound, range.upperBound.prev)
			self.width = width
			self.height = height
		}
		
		var description: String {
			"[\(range.lowerBound)..\(range.upperBound)], h: \(height, f: 2)"
		}
	}
	
	init(
		count: Int,
		heightAttitude: FlockHeight,
		alignment: Alignment,
		verticalSpacing: CGFloat,
		horizontalSpacing: CGFloat,
		linesLimit: FlockLines,
		debug: Bool
	) {
		self.count = count
		self.heightAttitude = heightAttitude
		self.alignment = alignment
		self.verticalSpacing = verticalSpacing
		self.horizontalSpacing = horizontalSpacing
		self.linesLimit = linesLimit
		self.debug = debug
		
		self.sizes = .init(repeating: .zero, count: count)
		self._frames = .init(initialValue: .init(repeating: .zero, count: count))
		self.debugStates = .init(repeating: .empty, count: count)
		
		switch heightAttitude {
		case .fit:
			self.height = .infinity
			self.width = .infinity
		case .expand:
			self.height = .zero
			self.width = .zero
		}
	}
	
	// MARK: Methods
	
	func reset(_ count: Int) {
		if debug { print("reset [\(count)]") }
		self.count = count
		self.sizes = .init(repeating: .zero, count: count)
		self.lines = .empty
		self.frames = .init(repeating: .zero, count: count)
		self.debugStates = .init(repeating: .empty, count: count)
		
		resetSize()
	}
	
	func resetSize() {
		self.minWidth = .zero
		self.minHeight = .zero
		switch heightAttitude {
		case .fit:
			self.height = .infinity
			self.width = .infinity
		case .expand:
			self.height = .zero
			self.width = .zero
		}
	}
	
	func save(size: CGSize, at index: Int) {
		if debug { print("save [\(index)] size") }
		guard sizes.count > index else {
			if debug { print(.tab + "! index is out of range") }
			return
		}
		sizes[index] = max(size, sizes[index])
		layoutIfPossible()
	}
	
	func fit(in size: CGSize) {
		switch heightAttitude {
		case .fit:    space.size = size
		case .expand: space.size = [size.width, .infinity]
		}
		layoutIfPossible()
	}
	
	// MARK: Calculate
	
	private var haveSpace: Bool {
		switch heightAttitude {
		case .fit:    return space.area.isNotZero
		case .expand: return space.width.isNotZero
		}
	}
	
	private func layoutIfPossible() {
		guard count.isNotZero else {
			self.lines = .empty
			self.width = .zero
			self.height = .zero
			self.minWidth = .zero
			self.minHeight = .zero
			return
		}
		
		guard haveSpace,
			  sizes.lazy.filter(\.isNotZero).count == count
		else { return }
		
		var debugStates: [[String]] = .init(repeating: .empty, count: count)
		var frames: [CGRect] = .init(repeating: .zero, count: count)
		var lines: [Line] = .empty
		
		var cursor = CGPoint.zero
//			var lineIndex: Int = .zero
		var lineStart: Int = .zero
		var lineHeight: CGFloat = .zero
		for index in .zero ..< count {
			let size = sizes[index]
			var frame = CGRect(cursor, size)
//				let fits = space.contains(frame)
			var fits = frame.maxX <= space.maxX
			
			if not(fits), lineStart == index {
				if debug { debugStates[index].append("fill") }
				/// first element doesn't fit line
				fits = true
				frame = frame.width(space.width)
				frames[index] = frame
				lineHeight = size.height
				cursor = cursor.offset(y: lineHeight + verticalSpacing)
				lines.append(
					Line(
						for: lineStart ... lineStart,
						width: frame.maxX,
						height: lineHeight
					)
				)
				lineHeight = .zero
				lineStart = index.next
				continue
			}
			
			if fits {
				debugStates[index].append("fit")
				/// update line height
				lineHeight = max(lineHeight, size.height)
				/// move the cursor right
				cursor = frame.topTrailing.offset(x: horizontalSpacing)
			}
			
			if not(fits) {
				if debug { debugStates[index].append("next line") }
				
				/// save previous line
				lines.append(
					Line(
						for: lineStart ..< index,
						width: cursor.x - verticalSpacing,
						height: lineHeight
					)
				)
				
				/// next line cursor
				cursor = cursor
					.moving(x: .zero)
					.offset(y: lineHeight + verticalSpacing)
				
				/// frame on the next line
				frame = CGRect(cursor, size)
				fits = frame.maxX <= space.maxX
				if not(fits) {
					if debug { debugStates[index].append("fill") }
					/// first in line element doesn't fit
					frame = frame.width(space.width)
				}
				
				/// **set new line** height and start
				lineHeight = size.height
				lineStart = index
				/// move the cursor right
				cursor = frame.topTrailing.offset(x: horizontalSpacing)
			}
			
			if index.next == count {
				if debug { debugStates[index].append("last line \(lineStart)-\(index)") }
				lines.append(
					Line(
						for: lineStart ... index,
						width: frame.maxX,
						height: lineHeight
					)
				)
			}
			
			frames[index] = frame
		}
		
		if alignment.horizontal != .leading {
			for line in lines {
				let dx: CGFloat
				if alignment.horizontal == .center {
					dx = (space.width - line.width).half
				} else if alignment.horizontal == .trailing {
					dx = space.width - line.width
				} else {
					/// Should never happen
					dx = .zero
				}
				
				for index in line.range {
					frames[index] = frames[index].offset(x: dx)
				}
			}
		}
		
		if alignment.vertical != .top {
			for line in lines {
				let lineHeight = line.height
				for index in line.range {
					let frame = frames[index]
					let dy: CGFloat
					if alignment.vertical == .center {
						dy = (lineHeight - frame.height).half
					} else if alignment.vertical == .bottom {
						dy = lineHeight - frame.height
					} else {
						/// Should never happen
						dy = .zero
					}
					
					frames[index] = frame.offset(y: dy)
				}
			}
		}
		
		if debug {
			self.debugStates = debugStates.map { $0.joined(separator: .comaspace) }
		}
		self.lines = lines
		self.frames = frames
		
		let numLines = min(lines.count, linesLimit.amount)
		self.lastVisibleIndex = lines[numLines.prev].range.upperBound
		
		self.width =
			lines
				.prefix(linesLimit.amount) /// only visible lines
				.map(\.range.upperBound) /// indexes of trailing elements
				.map { frames[$0] } /// trailing frames
				.map(\.maxX) /// line widths
				.max() /// max width
				.orZero
		
		self.minWidth =
			sizes
				.prefix(lastVisibleIndex.next)
				.map(\.width)
				.max()
				.orZero
		
		switch linesLimit {
		case .one:
			self.height = lines.first?.height ?? .zero
		case .some(let amount):
			let requiredLines = lines.prefix(amount)
			self.height = requiredLines.sum(of: \.height)
						+ requiredLines.count.prev * verticalSpacing
		case .unlimited:
			self.height = lines.sum(of: \.height)
						+ lines.count.prev * verticalSpacing
		}
		
		self.minHeight = lines.first?.height ?? .zero
	}
}

// MARK: Previews

#if DEBUG
@available(iOS 14, *)
struct Flock_Previews: PreviewProvider {
	struct Tag: View {
		let word: String
		
		init(_ word: String) {
			self.word = word
		}
		
		var body: some View {
			Text(word)
				.regular(4 + word.count.cg)
				.fixedSize()
				.padding(4)
				.padding(.horizontal, 2)
				.roundedBorder(.orange, radius: 6, weight: 2)
		}
	}
	
	struct TestView: View {
		@State var offset: Int
		@State var amount: Int
		@State var width: CGFloat
		
		static var words: [String] {
			[
				"World",
				"Happiness",
				"No",
				"Enhancement",
				"Hash",
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
		}
		
		init() {
			self._offset = .init(initialValue: .zero)
			self._amount = .init(initialValue: 6)
			self._width = .init(initialValue: 150) // 90
		}
		
		var body: some View {
			VStack(alignment: .leading, spacing: 32) {
				/*
				VStack {
					Text("Button test")
					
					Flock(
						of: Self.words.prefix(amount),
						height: .fit,
						linesLimit: .one
					) { word in
						Tag(word)
					}
				}
				.padding()
				.maxWidth()
				.systemBackground()
				.button()
				.buttonStyleCard(size: .big)
				*/
				
				Flock(
					of: Self.words.prefix(amount),
					height: .fit,
					linesLimit: .one
				) { word in
					Tag(word)
						.opacity(0.3)
				}
				.width(width, .trailing)
				.border.c2()
				.delete()
				
				Flock(
					of: Self.words.prefix(amount),
					height: .fit,
					alignment: .trailing,
					linesLimit: .one,
					debug: true
				) { word in
					Tag(word)
						.opacity(0.3)
				}
				.width(width)
				.border.c2()
				.delete()

				Flock(
					of: Self.words.prefix(amount),
					height: .fit,
					alignment: .center,
					linesLimit: .some(2),
					debug: false
				) { word in
					Tag(word)
						.opacity(0.3)
				}
				.width(width)
				.border.c5()
				.delete()
				
				Flock(
					of: Self.words.dropFirst(offset).prefix(amount),
					height: .fit,
					alignment: .bottomTrailing,
					debug: true
				) { word in
					Tag(word)
						.transition(AnyTransition.scale(scale: 0.5).combined(with: .opacity).animation(.spring()))
				}
				.width(width)
				.border.c3()
				
				Color.pink.height(4).width(width)
				
				ScrollView {
					Flock(
						of: Self.words.prefix(amount),
						height: .fit,
						alignment: .center
					) { word in
						Tag(word)
					}
					.width(width, .center)
					.border.c4()
					
					Flock(
						of: Self.words.prefix(amount),
						height: .fit,
						linesLimit: .one
					) { word in
						Tag(word)
							.opacity(0.3)
					}
					.width(width, .trailing)
					.border.c9()
				}
				.delete()
				Spacer()
				
				HStack {
					Group {
						Button("width + 10", assign: width + 10, to: \.width, on: self)
						Button("width - 10", assign: width - 10, to: \.width, on: self)
						Button("+ Start", assign: offset + 1, to: \.offset, on: self)
						Button("- Start", assign: (offset - 1).clippedAboveZero(), to: \.offset, on: self)
						Button("+ Tag", assign: amount + 1, to: \.amount, on: self)
						Button("- Tag", assign: (amount - 1).clippedAboveZero(), to: \.amount, on: self)
					}
					.padding(4)
					.round(6, border: .green, weight: 1)
				}
//				.buttonStyleOutlined()
				.semibold(8)
				.height(40)
				.maxWidth()
				.border.c5()
			}
//			.animation(.spring())
		}
	}
	
	static var previews: some View {
		Group {
			TestView()
//				.height(1000)
				.previewFitting()
		}
	}
}
#endif
