//
//  LabeledValueView.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 28.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: - Environment Values

extension EnvironmentValues {
	@Entry public var labeledViewLengthLimit: Int = 50
	@Entry public var labeledViewMaxValueWidth: CGFloat? = 256
	@Entry public var labeledViewAllowMultiline: Bool = false
	@Entry public var labeledViewIsInLabeledColumnsLayout: Bool = false
	@Entry public var labeledViewMaxLabelFraction: CGFloat = 0.45
}

extension View {
	/// Sets a maximum character limit (`50` dy default)
	/// for all `LabeledValueView` instances in this view hierarchy.
	///
	/// Use this modifier to override the default limit of 50 characters when displaying
	/// value labels, truncating any text that exceeds the specified length.
	///
	/// - Parameter length: The maximum number of characters to display for value labels.
	/// - Returns: A view that applies the specified length limit
	/// 	to the `labeledViewLengthLimit` environment key.
	public func setLabeledView(lengthLimit length: Int) -> some View {
		environment(\.labeledViewLengthLimit, length)
	}
	
	@available(*, deprecated, renamed: "setLabeledView(allowMultiline:)", message: "Labeled view environment value functions were renamed for consistency.")
	public func labeledViewLengthLimit(_ length: Int) -> some View {
		environment(\.labeledViewLengthLimit, length)
	}
	
	public func setLabeledView(allowMultiline value: Bool) -> some View {
		environment(\.labeledViewAllowMultiline, value)
	}
	
	public func setLabeledView(maxValueWidth value: CGFloat?) -> some View {
		environment(\.labeledViewMaxValueWidth, value)
	}
	
	public func setLabeledView(isInColumnLayout value: Bool) -> some View {
		environment(\.labeledViewIsInLabeledColumnsLayout, value)
	}

	public func setLabeledView(maxLabelFraction fraction: CGFloat) -> some View {
		environment(\.labeledViewMaxLabelFraction, fraction)
	}
}

// MARK: - Layout
/// (two columns)

fileprivate enum LabeledRole: Hashable, Sendable, CaseIterable {
	case label
	case value
}

fileprivate struct LabeledRoleKey: LayoutValueKey {
	static let defaultValue: LabeledRole = .value
}

/// A layout that expects children in pairs: label, value, label, value, ...
/// It computes a common label column width and aligns labels trailing and values leading.
public struct LabeledColumnsLayout: Layout {
	public var spacing: CGFloat = 2
	public var maxLabelFraction: CGFloat = 0.45
	
	public init(spacing: CGFloat = 2, maxLabelFraction: CGFloat = 0.45) {
		self.spacing = spacing
		self.maxLabelFraction = maxLabelFraction
	}

	public struct Cache {
		var labelWidth: CGFloat = .zero
		var rowHeights: [CGFloat] = .empty
	}
	
	public func makeCache(subviews: Subviews) -> Cache { .init() }
	public func updateCache(_ cache: inout Cache, subviews: Subviews) {}

	public func sizeThatFits(
		proposal: ProposedViewSize,
		subviews: Subviews,
		cache: inout Cache
	) -> CGSize {
		let availW = proposal.width ?? .infinity
		guard !subviews.isEmpty else { return .zero }

		/// 1) widest label
		var maxLabel: CGFloat = 0
		for s in subviews where s[LabeledRoleKey.self] == .label {
			let sz = s.sizeThatFits(.init(width: availW, height: .infinity))
			maxLabel = max(maxLabel, sz.width)
		}
		/// cap so label can't eat all width
		maxLabel = min(maxLabel, max(0, availW * maxLabelFraction))

		/// 2) per-row heights using actual column widths
		var heights: [CGFloat] = []
		var i = 0
		while i < subviews.count {
			let label = subviews[i]
			let value = i + 1 < subviews.count ? subviews[i + 1] : subviews[i]
			let hLabel = label.sizeThatFits(.init(width: maxLabel, height: .infinity)).height
			let valueW = max(0, availW - maxLabel - spacing)
			let hValue = value.sizeThatFits(.init(width: valueW, height: .infinity)).height
			heights.append(max(hLabel, hValue))
			i += 2
		}

		cache.labelWidth = maxLabel
		cache.rowHeights = heights
		let totalH = heights.reduce(0, +) + CGFloat(max(0, heights.count - 1)) * spacing
		return CGSize(width: availW, height: totalH)
	}

	public func placeSubviews(
		in bounds: CGRect,
		proposal: ProposedViewSize,
		subviews: Subviews,
		cache: inout Cache
	) {
		/// Recompute widths & heights every placement
		/// to avoid stale cache when content toggles line limits.
		
		var maxLabel: CGFloat = 0
		for s in subviews where s[LabeledRoleKey.self] == .label {
			let sz = s.sizeThatFits(.init(width: bounds.width, height: .infinity))
			maxLabel = max(maxLabel, sz.width)
		}
		let labelW = min(maxLabel, max(0, bounds.width * maxLabelFraction))
		let valueW = max(0, bounds.width - labelW - spacing)

		var y = bounds.minY
		var i = 0
		while i < subviews.count {
			let label = subviews[i]
			let value = i + 1 < subviews.count ? subviews[i + 1] : subviews[i]
			let hLabel = label.sizeThatFits(.init(width: labelW, height: .infinity)).height
			let hValue = value.sizeThatFits(.init(width: valueW, height: .infinity)).height
			let h = max(hLabel, hValue)

			label.place(
				at: CGPoint(x: bounds.minX + labelW, y: y),
				anchor: .topTrailing,
				proposal: .init(width: labelW, height: h)
			)
			value.place(
				at: CGPoint(x: bounds.minX + labelW + spacing, y: y),
				anchor: .topLeading,
				proposal: .init(width: valueW, height: h)
			)

			y += h + spacing
			i += 2
		}
	}
}

// MARK: - Stack

public struct LabeledViews<Views: View>: View {
	public let spacing: CGFloat
	public let views: Views
	
	@Environment(\.labeledViewIsInLabeledColumnsLayout) fileprivate var inLayout
	@Environment(\.labeledViewMaxLabelFraction) fileprivate var maxLabelFraction
	
	public init(spacing: CGFloat = 2, @ViewBuilder _ views: () -> Views) {
		self.spacing = spacing
		self.views = views()
	}
	
	public var body: some View {
		if inLayout {
			views
		} else {
			LabeledColumnsLayout(spacing: spacing, maxLabelFraction: maxLabelFraction) {
				views
			}
			.setLabeledView(isInColumnLayout: true)
		}
	}
}

// MARK: - View

public struct LabeledValueView: View {
	fileprivate var valueView: ValueView
	fileprivate var label: String?
	
	@Environment(\.colorScheme) fileprivate var colorScheme
	@Environment(\.pixelLength) fileprivate var pixelLength
	@Environment(\.labeledViewAllowMultiline) fileprivate var allowMultiline
	@Environment(\.labeledViewMaxValueWidth) fileprivate var maxValueWidth
	@Environment(\.labeledViewIsInLabeledColumnsLayout) fileprivate var inLayout
	
	private init(
		valueView: ValueView,
		label: String?
	) {
		self.valueView = valueView
		self.label = label?
			.withLinesNSpacesTrimmed
			.toRegularSentenceCase
			.nonEmpty
	}
	
	public init <S: StringProtocol> (
		_ value: S?,
		label: String? = nil
	) {
		switch value {
		case .none:
			self.init(
				valueView: .undefined(.x),
				label: label
			)
		case .some(let wrapped):
			self.init(
				valueView: .string(String(wrapped)),
				label: label
			)
		}
	}
	
	public init(
		_ value: CGFloat?,
		label: String? = nil,
		fractionDigits: UInt = 0
	) {
		switch value {
		case .none: 			 self.init(valueView: .undefined(.x), label: label)
		case .some(let wrapped): self.init(valueView: .cgFloat(wrapped), label: label)
		}
	}
	
	public init <F: FixedWidthInteger & SignedInteger> (
		 _ value: F?,
		   label: String? = .none
	) {
		switch value {
		case .none: 			 self.init(valueView: .undefined(.x), label: label)
		case .some(let wrapped): self.init(valueView: .integer(wrapped), label: label)
		}
	}
	
	public init <F: FixedWidthInteger & UnsignedInteger> (
		 _ value: F?,
		   label: String? = .none
	) {
		switch value {
		case .none: 			 self.init(valueView: .undefined(.x), label: label)
		case .some(let wrapped): self.init(valueView: .unsignedInteger(wrapped), label: label)
		}
	}
	
	public init <F: BinaryFloatingPoint & CVarArg> (
		 _ value: F?,
		   label: String? = .none,
		fraction: Int     = .zero
	) {
		switch value {
		case .none: 			 self.init(valueView: .undefined(.x), label: label)
		case .some(let wrapped): self.init(valueView: .floatingPoint(wrapped), label: label)
		}
	}

	public init(
		_ value: CGRect?,
		label: String? = nil,
		fractionDigits: Int = 0
	) {
		switch value {
		case .none: 			 self.init(valueView: .undefined(.x), label: label)
		case .some(let wrapped): self.init(valueView: .cgRect(wrapped, fraction: fractionDigits), label: label)
		}
	}
	
	public init(
		_ value: CGPoint?,
		label: String? = nil,
		fractionDigits: Int = 0
	) {
		switch value {
		case .none: 			 self.init(valueView: .undefined(.x), label: label)
		case .some(let wrapped): self.init(valueView: .cgPoint(wrapped, fraction: fractionDigits), label: label)
		}
	}
	
	public init(
		_ value: CGVector?,
		label: String? = nil,
		fractionDigits: Int = 0
	) {
		switch value {
		case .none: 			 self.init(valueView: .undefined(.x), label: label)
		case .some(let wrapped): self.init(valueView: .cgVector(wrapped, fraction: fractionDigits), label: label)
		}
	}
	
	public init(
		_ value: CGSize?,
		label: String? = nil,
		fractionDigits: Int = 0
	) {
		switch value {
		case .none: 			 self.init(valueView: .undefined(.x), label: label)
		case .some(let wrapped): self.init(valueView: .cgSize(wrapped, fraction: fractionDigits), label: label)
		}
	}
	
	#if canImport(UIKit)
	public init(
		_ value: UIEdgeInsets?,
		label: String? = nil,
		fractionDigits: Int = 0
	) {
		switch value {
		case .none: 			 self.init(valueView: .undefined(.x), label: label)
		case .some(let wrapped): self.init(valueView: .edgeInsets(wrapped.asEdgeInsets(), fraction: fractionDigits), label: label)
		}
	}
	#endif
	
	public init(
		_ value: EdgeInsets?,
		label: String? = nil,
		fractionDigits: Int = 0
	) {
		switch value {
		case .none: 			 self.init(valueView: .undefined(.x), label: label)
		case .some(let wrapped): self.init(valueView: .edgeInsets(wrapped, fraction: fractionDigits), label: label)
		}
	}
	
	public init(
		_ value: Date?,
		label: String? = nil,
		dateStyle: Date.FormatStyle.DateStyle = .numeric,
		timeStyle: Date.FormatStyle.TimeStyle = .shortened
	) {
		switch value {
		case .none: 			 self.init(valueView: .undefined(.x), label: label)
		case .some(let wrapped): self.init(valueView: .string(wrapped.formatted(date: dateStyle, time: timeStyle)), label: label)
		}
	}
	
	public init(
		_ value: Bool?,
		label: String? = nil,
		boolDisplayStyle style: BoolDisplayStyle = .default
	) {
		switch value {
		case .none: 			 self.init(valueView: .undefined(.x), label: label)
		case .some(let wrapped): self.init(valueView: .bool(wrapped, display: style), label: label)
		}
	}
	
	static private func bool(value: Bool) -> some View {
		Image.bool(value)
			.semibold(8)
			.padding(.horizontal, 5)
			.foregroundStyle(.primary)
			.maxHeight(.center)
	}
	
	public init<EnumValue: EasySelfComparable>(
		_ value: EnumValue?,
		label: String? = nil
	) {
		switch value {
		case .none: 			 self.init(valueView: .undefined(.x), label: label)
		case .some(let wrapped): self.init(valueView: .string(".\(caseName(of: wrapped, [.name, .arguments]))"), label: label)
		}
	}
	
	public init(
		describing value: CustomStringConvertible?,
		label: String? = nil
	) {
		switch value {
		case .none: 			 self.init(valueView: .undefined(.x), label: label)
		case .some(let wrapped): self.init(valueView: .string(wrapped.description), label: label)
		}
	}
	
	fileprivate let shape = RoundedRectangle(cornerRadius: 2, style: .continuous)
	
	// MARK: Body (new)
	
	public var body: some View {
		if inLayout {
			
			/// Emit two siblings for the layout (`label`, `value`)
			
			labelView()
			valueViewBody()
			
		} else {
			
			/// Backward-compatible single-row presentation
			
			let labelRatio: CGFloat = 0.28
			let valueRatio: CGFloat = 1 - labelRatio
			let spacing: CGFloat = 1
			
			HStack(alignment: .top, spacing: spacing) {
				labelView()
					.containerRelativeFrame(
						[.horizontal, .vertical],
						alignment: .topTrailing
					) { length, axis in
						switch axis {
						case .horizontal: (length - spacing) * labelRatio
						case .vertical where allowMultiline: length
						case .vertical: 15
						}
					}
				valueViewBody()
					.containerRelativeFrame(
						[.horizontal, .vertical],
						alignment: .topLeading
					) { length, axis in
						switch axis {
						case .horizontal: (length - spacing) * valueRatio
						case .vertical where allowMultiline: length
						case .vertical: 15
						}
					}
			}
			.compositingGroup()
			.shadow(color: colorScheme.isDark ? .clear : .black.opacity(0.4), radius: 2)
			.containerRelativeFrame(
				[.horizontal, .vertical],
				alignment: .topLeading
			) { length, axis in
				switch axis {
				case .horizontal: length
				case .vertical where allowMultiline: length
				case .vertical: 15
				}
			}
		}
	}
	
	// MARK: ┣ Label
	
	@ViewBuilder
	fileprivate func labelView() -> some View {
		if let label {
			label
				.asText()
				.multilineTextAlignment(.trailing)
				.font(.system(size: 10, weight: .semibold).smallCaps())
				.padding(EdgeInsets(top: 1, leading: 5, bottom: 2, trailing: 5))
				.foregroundStyle(.secondary)
				.frame(minHeight: 15, alignment: .topTrailing)
				.background(.regularMaterial, in: shape)
				.clipShape(shape)
				.overlay {
					if colorScheme.isDark {
						shape.inset(by: LinePosition.inner.inset(for: pixelLength))
							.strokeBorder(.tertiary, lineWidth: pixelLength)
					}
				}
				.contentShape([.contextMenuPreview, .hoverEffect, .interaction, .dragPreview], shape)
				.hoverEffect(.highlight)
				.fixedHeight()
				.apply { view in
					ViewThatFits(in: .horizontal) {
						view.lineLimit(1)
						view
					}
				}
				.apply(when: inLayout) { v in
					v.compositingGroup()
						.shadow(
							color: colorScheme.isDark ? .clear : .black.opacity(0.4),
							radius: 2
						)
				}
				.layoutValue(key: LabeledRoleKey.self, value: .label)
		}
	}
	
	// MARK: ┗ Value
	
	@ViewBuilder
	fileprivate func valueViewBody() -> some View {
		valueView
			.multilineTextAlignment(.leading)
			.frame(minHeight: 15, alignment: .topLeading)
			.background(.systemBackground, in: shape)
			.clipShape(shape)
			.overlay {
				if colorScheme.isDark {
					shape.inset(by: LinePosition.inner.inset(for: pixelLength))
						.strokeBorder(.tertiary, lineWidth: pixelLength)
				}
			}
			.contentShape([.contextMenuPreview, .hoverEffect, .interaction, .dragPreview], shape)
			.hoverEffect(.highlight)
			.asMultilineSwitcher()
			.contextMenu {
				Label {
					Text("Copy", tableName: "Debug", comment: "Copy labeled view value string to clipboard")
				} icon: {
					Image(systemName: "doc.on.doc")
				}
				.button {
					UIPasteboard.general.string = valueView.string
				}
				
				ShareLink(item: valueView.string) {
					Label {
						Text("Share", tableName: "Debug", comment: "Share labeled view value string")
					} icon: {
						Image(systemName: "square.and.arrow.up")
					}
				}
			}
			.apply(when: inLayout) { v in
				v.compositingGroup()
					.shadow(
						color: colorScheme.isDark ? .clear : .black.opacity(0.4),
						radius: 2
					)
			}
			.draggable(valueView.transferableText)
			.layoutValue(key: LabeledRoleKey.self, value: .value)
	}

	
	// MARK: Body (old)
	
	/*
	public var body: some View {
		// let maxValueWidth = maxValueWidth ?? 300
		let labelRatio: CGFloat = 0.28
		let valueRatio: CGFloat = 1 - labelRatio
		let spacing: CGFloat = 1
		
		HStack(alignment: .top, spacing: spacing) {
			
			label?
				.asText()
				// .lineLimit(1)
				.multilineTextAlignment(.trailing)
				.font(Font.system(size: 10, weight: .semibold).smallCaps())
				.padding(EdgeInsets(top: 1, leading: 5, bottom: 2, trailing: 5))
				.foregroundStyle(.secondary)
				.frame(minHeight: 15, alignment: .topTrailing)
				
				.background(.regularMaterial, in: shape) /// `Color.primary.opacity(0.6)`
				.clipShape(shape)
				.overlay {
					if colorScheme.isDark {
						shape.inset(by: LinePosition.inner.inset(for: pixelLength))
							.strokeBorder(.tertiary, lineWidth: pixelLength)
					}
				}
				.contentShape([.contextMenuPreview, .hoverEffect, .interaction, .dragPreview], shape)
				.hoverEffect(.highlight)
				
				.fixedHeight()
				.apply { view in
					ViewThatFits(in: .horizontal) {
						view.lineLimit(1)
						view
					}
				}
				// .containerRelativeFrame(.horizontal, count: 10, span: 3, spacing: spacing, alignment: .trailing)
				.containerRelativeFrame(
					[.horizontal, .vertical],
					alignment: .topTrailing
				) { length, axis in
					switch axis {
					case .horizontal: (length - spacing) * labelRatio
					case .vertical where allowMultiline: length
					case .vertical: 15
					}
				}
				// .alignmentGuide(.separator) { $0.width }
			
			valueView
				.multilineTextAlignment(.leading)
				.frame(minHeight: 15, alignment: .topLeading)
				// .alignmentGuide(.separator, value: .zero)
				
				.background(.systemBackground, in: shape)
				.clipShape(shape)
				.overlay {
					if colorScheme.isDark {
						shape.inset(by: LinePosition.inner.inset(for: pixelLength))
							.strokeBorder(.tertiary, lineWidth: pixelLength)
					}
				}
				.contentShape([.contextMenuPreview, .hoverEffect, .interaction, .dragPreview], shape)
				.hoverEffect(.highlight)
				
				/*
				.background(Color.systemBackground)
				.roundedBorder(
					Color.primary.opacity(0.6),
					radius: 2,
					weight: colorScheme.isDark ? pixelLength : 0
				)
				*/
				
				.asMultilineSwitcher()
				.contextMenu {
					Label {
						Text("Copy", tableName: "Debug", comment: "Copy labeled view value string to clipboard")
					} icon: {
						Image(systemName: "doc.on.doc")
					}
					.button {
						UIPasteboard.general.string = valueView.string
					}

					ShareLink(item: valueView.string) {
						Label {
							Text("Share", tableName: "Debug", comment: "Share labeled view value string")
						} icon: {
							Image(systemName: "square.and.arrow.up")
						}
					}
				}
				.draggable(valueView.transferableText)
				.containerRelativeFrame(
					[.horizontal, .vertical],
					alignment: .topLeading
				) { length, axis in
					switch axis {
					case .horizontal: (length - spacing) * valueRatio
					case .vertical where allowMultiline: length
					case .vertical: 15
					}
				}
		}
		.compositingGroup()
		.shadow(
			color: colorScheme.isDark ? .clear : .black.opacity(0.4),
			radius: 2
		)
		.containerRelativeFrame(
			[.horizontal, .vertical],
			alignment: .topLeading
		) { length, axis in
			switch axis {
			case .horizontal: length
			case .vertical where allowMultiline: length
			case .vertical: 15
			}
		}
		// .containerRelativeFrame(.horizontal)
		/*
		.apply { view in
			ViewThatFits(in: .horizontal) {
				view
				view.setLabeledView(maxValueWidth: maxValueWidth - 20)
				view.setLabeledView(maxValueWidth: maxValueWidth - 40)
				view.setLabeledView(maxValueWidth: maxValueWidth - 60)
				view.setLabeledView(maxValueWidth: maxValueWidth - 80)
				view.setLabeledView(maxValueWidth: maxValueWidth - 100)
				/*
				if allowMultiline {
					view.alignmentGuide(.separator, value: 0)
				}
				*/
			}
		}
		*/
		/*
		.apply { view in
			ViewThatFits(in: .horizontal) {
				view
				if allowMultiline {
					view.alignmentGuide(.separator, value: 0)
				}
			}
		}
		*/
	}
	*/
}

// MARK: - Bool Display Style

extension LabeledValueView {
	public enum BoolDisplayStyle: Hashable, Sendable, DefaultCaseFirst {
		case icon
		case string
		case int
		case emoji
	}
}

// MARK: - Multiline Switcher

public struct LabeledViewMultilineSwitcher<Content: View>: View {
	public let content: Content
	
	@State private var isSwitched: Bool = false
	
	@Environment(\.labeledViewLengthLimit) fileprivate var lengthLimit
	@Environment(\.labeledViewMaxValueWidth) fileprivate var maxValueWidth
	@Environment(\.labeledViewAllowMultiline) fileprivate var allowMultiline
	
	public init(@ViewBuilder _ content: () -> Content) {
		self.content = content()
	}
	
	public var body: some View {
		let isMultiline: Bool = isSwitched ? not(allowMultiline) : allowMultiline
		// let newlengthLimit: Int = isMultiline ? .max : (lengthLimit == .max ? 40 : lengthLimit)
		
		content
			// .setLabeledView(lengthLimit: newlengthLimit)
			.setLabeledView(allowMultiline: isMultiline)
			// .maxWidth(maxValueWidth, .leading)
			/*
			.fixedWidth()
			.clipped()
			*/

			.lineLimit(isMultiline ? nil : 1)
			// .fixedHeight(isMultiline)
			// .alignmentGuide(.separator) { $0[.leading] }
			.button {
				withAnimation(.bouncy) {
					isSwitched.toggle()
				}
			}
			.buttonStyle(.plain)
			.id(isMultiline)
	}
}

extension View {
	@inlinable public func asMultilineSwitcher() -> some View {
		LabeledViewMultilineSwitcher { self }
	}
}

public extension String {
	@inlinable @MainActor func labeledView(label: String? = nil) -> LabeledValueView {
		LabeledValueView(self, label: label)
	}
}
public extension Optional where Wrapped == String {
	@inlinable @MainActor func labeledView(label: String? = nil) -> LabeledValueView {
		LabeledValueView(self, label: label)
	}
}
public extension Binding where Value == String {
	@inlinable @MainActor func labeledView(label: String? = nil) -> LabeledValueView {
		LabeledValueView(wrappedValue, label: label)
	}
}

public extension CGFloat {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: UInt) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: UInt = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}
public extension Optional where Wrapped == CGFloat {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: UInt) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: UInt = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}

public extension FixedWidthInteger where Self: SignedInteger {
	@inlinable @MainActor func labeledView(label: String? = .none) -> LabeledValueView {
		LabeledValueView(self, label: label)
	}
}

public extension Optional where Wrapped: FixedWidthInteger, Wrapped: SignedInteger {
	@inlinable @MainActor func labeledView(label: String? = .none) -> LabeledValueView {
		LabeledValueView(self, label: label)
	}
}

public extension FixedWidthInteger where Self: UnsignedInteger {
	@inlinable @MainActor func labeledView(label: String? = .none) -> LabeledValueView {
		LabeledValueView(self, label: label)
	}
}

public extension Optional where Wrapped: FixedWidthInteger, Wrapped: UnsignedInteger {
	@inlinable @MainActor func labeledView(label: String? = .none) -> LabeledValueView {
		LabeledValueView(self, label: label)
	}
}

public extension BinaryFloatingPoint where Self: CVarArg {
	@inlinable @MainActor func labeledView(label: String? = .none, f digits: Int) -> LabeledValueView {
		LabeledValueView(self, label: label, fraction: digits)
	}
}

public extension Optional where Wrapped: BinaryFloatingPoint, Wrapped: CVarArg {
	@inlinable @MainActor func labeledView(label: String? = .none, f digits: Int) -> LabeledValueView {
		LabeledValueView(self, label: label, fraction: digits)
	}
}

public extension CGSize {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: Int) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: Int = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}
public extension Optional where Wrapped == CGSize {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: Int) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: Int = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}

public extension CGPoint {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: Int) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: Int = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}
public extension Optional where Wrapped == CGPoint {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: Int) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: Int = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}

// MARK: ┣ CGVector

public extension CGVector {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: Int) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
}
public extension Optional<CGVector> {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: Int) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
}

// MARK: ┣ CGRect

public extension CGRect {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: Int) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: Int = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}
public extension Optional where Wrapped == CGRect {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: Int) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: Int = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}

#if canImport(UIKit)
public extension UIEdgeInsets {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: Int) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: Int = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}
public extension Optional where Wrapped == UIEdgeInsets {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: Int) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: Int = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}
#endif

public extension EdgeInsets {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: Int) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: Int = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}
public extension Optional where Wrapped == EdgeInsets {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: Int) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: Int = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}

public extension Date {
	@inlinable @MainActor func labeledView(
		label: String? = nil,
		dateStyle: Date.FormatStyle.DateStyle = .numeric,
		timeStyle: Date.FormatStyle.TimeStyle = .shortened
	) -> LabeledValueView {
		LabeledValueView(
			self,
			label: label,
			dateStyle: dateStyle,
			timeStyle: timeStyle
		)
	}
}
public extension Optional where Wrapped == Date {
	@inlinable @MainActor func labeledView(
		label: String? = nil,
		dateStyle: Date.FormatStyle.DateStyle = .numeric,
		timeStyle: Date.FormatStyle.TimeStyle = .shortened
	) -> LabeledValueView {
		LabeledValueView(
			self,
			label: label,
			dateStyle: dateStyle,
			timeStyle: timeStyle
		)
	}
}

public extension Bool {
	@inlinable @MainActor func labeledView(
		label: String? = nil,
		boolDisplayStyle: LabeledValueView.BoolDisplayStyle = .default
	) -> LabeledValueView {
		LabeledValueView(
			self,
			label: label,
			boolDisplayStyle: boolDisplayStyle
		)
	}
}
public extension Optional where Wrapped == Bool {
	@inlinable @MainActor func labeledView(
		label: String? = nil,
		boolDisplayStyle: LabeledValueView.BoolDisplayStyle = .default
	) -> LabeledValueView {
		LabeledValueView(
			self,
			label: label,
			boolDisplayStyle: boolDisplayStyle
		)
	}
}
public extension Binding where Value == Bool {
	@inlinable @MainActor func labeledView(
		label: String? = nil,
		boolDisplayStyle: LabeledValueView.BoolDisplayStyle = .default
	) -> LabeledValueView {
		LabeledValueView(
			wrappedValue,
			label: label,
			boolDisplayStyle: boolDisplayStyle
		)
	}
}

// MARK: Case View

public extension EasySelfComparable {
	@inlinable @MainActor func caseView(label: String? = nil) -> LabeledValueView {
		LabeledValueView(self, label: label)
	}
}

public extension Optional where Wrapped: EasySelfComparable {
	@inlinable @MainActor func caseView(label: String? = nil) -> LabeledValueView {
		LabeledValueView(self, label: label)
	}
}

public extension Binding where Value: EasySelfComparable {
	@inlinable @MainActor func caseView(label: String? = nil) -> LabeledValueView {
		LabeledValueView(self.wrappedValue, label: label)
	}
}

// MARK: Collection

/// A view that renders a collection of elements as a series of labeled rows.
///
/// Each element is displayed using `LabeledValueView`, with the element's index
/// used as the label by default. When placed inside `LabeledViews`/`LabeledColumnsLayout`,
/// the view emits individual label/value pairs so it composes into the two-column layout.
/// When used outside the layout, it wraps content in `LabeledViews` automatically.
///
/// If the collection is empty, the view shows a localized representation of an empty set
/// via `NilReplacement.emptySet.labeledView(label:)`.
public struct LabeledCollectionView<C: Collection>: View where C.Element: Sendable {
	public let collection: C
	public let label: String?
	
	@Environment(\.labeledViewIsInLabeledColumnsLayout) fileprivate var inLayout
	
	/// Creates a labeled view for a collection.
	///
	/// - Parameters:
	///   - collection: The collection to present. Elements are rendered using `LabeledValueView`.
	///   - label: An optional label shown as a header row. If `nil`, only items are shown.
	public init(for collection: C, label: String?) {
		self.collection = collection
		self.label = label
	}
	
	public var body: some View {
		if collection.isEmpty {
			NilReplacement.emptySet.labeledView(label: label)
		} else {
			if inLayout {
				/// Already inside the column layout - we do not put another Layout.
				if let label {
					"[\(C.Element.self)]".labeledView(label: label)
				}
				ForEach(enumerating: collection) { offset, element in
					switch element {
					case let item as CGRect:
						item.labeledView(label: "\(offset)", f: 2)
					case let item as CGSize:
						item.labeledView(label: "\(offset)", f: 2)
					case let item as CGPoint:
						item.labeledView(label: "\(offset)", f: 2)
					case let item as CGFloat:
						item.labeledView(label: "\(offset)", f: 2)
					default:
						"\(element)".labeledView(label: "\(offset)")
					}
				}
			} else {
				/// The usual (external) situation - we use ``LabeledViews`` layout.
				LabeledViews {
					if let label {
						"[\(C.Element.self)]".labeledView(label: label)
					}
					ForEach(enumerating: collection) { offset, element in
						switch element {
						case let item as CGRect:
							item.labeledView(label: "\(offset)", f: 2)
						case let item as CGSize:
							item.labeledView(label: "\(offset)", f: 2)
						case let item as CGPoint:
							item.labeledView(label: "\(offset)", f: 2)
						case let item as CGFloat:
							item.labeledView(label: "\(offset)", f: 2)
						default:
							"\(element)".labeledView(label: "\(offset)")
						}
					}
				}
			}
		}
	}
}

extension Collection where Element: Sendable {
	/// Presents this collection as a stack of labeled rows.
	///
	/// When called outside a `LabeledColumnsLayout`, the result is wrapped in `LabeledViews`
	/// to participate in a two-column layout. When already inside the layout, this produces
	/// label/value pairs directly. Empty collections render a localized "empty set" row.
	///
	/// - Parameter label: An optional header label describing the collection.
	/// - Returns: A view that displays the collection using `LabeledValueView` rows.
	@MainActor @inlinable public func labeledViews(label: String? = nil) -> some View {
		LabeledCollectionView(for: self, label: label)
	}
}

// MARK: Dictionary

/// A view that renders a dictionary as labeled rows.
///
/// Keys are used as labels and values are converted to strings and shown as values.
/// Behavior adapts to whether the view is already inside a `LabeledColumnsLayout`.
/// Empty dictionaries render a localized "empty set" row.
public struct LabeledDictionaryView<Key: Sendable & Hashable, Value: Sendable>: View {
	public let dictionary: [Key: Value]
	public let label: String?

	@Environment(\.labeledViewIsInLabeledColumnsLayout) fileprivate var inLayout

	/// Creates a labeled view for a dictionary.
	///
	/// - Parameters:
	///   - dictionary: The dictionary to present. Each key becomes a row label.
	///   - label: An optional header label describing the dictionary.
	public init(for dictionary: [Key: Value], label: String?) {
		self.dictionary = dictionary
		self.label = label
	}

	public var body: some View {
		if dictionary.isEmpty {
			NilReplacement.emptySet.labeledView(label: label)
		} else {
			if inLayout {
				/// Already inside the column layout - we do not put another Layout.
				if let label {
					"[\(Key.self): \(Value.self)]".labeledView(label: label)
				}
				ForEach(enumerating: dictionary) { offset, element in
					"\(element.value)".labeledView(label: "\(element.key)")
				}
			} else {
				/// The usual (external) situation - we use ``LabeledViews`` layout.
				LabeledViews {
					if let label {
						"[\(Key.self): \(Value.self)]".labeledView(label: label)
					}
					ForEach(enumerating: dictionary) { offset, element in
						"\(element.value)".labeledView(label: "\(element.key)")
					}
				}
			}
		}
	}
}

extension Dictionary where Key: Sendable, Value: Sendable {
	/// Presents this dictionary as labeled rows.
	///
	/// Keys are displayed as labels and values are stringified into `LabeledValueView`.
	/// - Parameter label: An optional header label describing the dictionary.
	/// - Returns: A view that displays the dictionary using `LabeledValueView` rows.
	@MainActor @inlinable public func labeledViews(label: String? = nil) -> some View {
		LabeledDictionaryView(for: self, label: label)
	}
}

// MARK: Set

/// A view that renders a set as labeled rows.
///
/// Elements are displayed using their string representation, with the row label being
/// the element's index in the iteration order. Behavior adapts to whether the view is
/// already inside a `LabeledColumnsLayout`. Empty sets render a localized "empty set" row.
public struct LabeledSetView<Element: Sendable & Hashable>: View {
	public let set: Set<Element>
	public let label: String?
	
	@Environment(\.labeledViewIsInLabeledColumnsLayout) fileprivate var inLayout
	
	/// Creates a labeled view for a set.
	///
	/// - Parameters:
	///   - set: The set to present. Elements are rendered as `LabeledValueView` rows.
	///   - label: An optional header label describing the set.
	public init(for set: Set<Element>, label: String?) {
		self.set = set
		self.label = label
	}
	
	public var body: some View {
		if set.isEmpty {
			NilReplacement.emptySet.labeledView(label: label)
		} else {
			if inLayout {
				/// Already inside the column layout - we do not put another Layout.
				if let label {
					"[\(Element.self)]".labeledView(label: label)
				}
				ForEach(enumerating: set) { offset, element in
					"\(element)".labeledView(label: "\(offset)")
				}
			} else {
				/// The usual (external) situation - we use ``LabeledViews`` layout.
				LabeledViews {
					if let label {
						"[\(Element.self)]".labeledView(label: label)
					}
					ForEach(enumerating: set) { offset, element in
						"\(element)".labeledView(label: "\(offset)")
					}
				}
			}
		}
	}
}

extension Set where Element: Sendable {
	/// Presents this set as labeled rows.
	///
	/// - Parameter label: An optional header label describing the set.
	/// - Returns: A view that displays the set using `LabeledValueView` rows.
	@MainActor @inlinable public func labeledViews(label: String? = .none) -> some View {
		LabeledSetView(for: self, label: label)
	}
}

// MARK: - Ordered Collections

import OrderedCollections

// MARK: OrderedDictionary

/// A view that renders an `OrderedDictionary` as labeled rows, preserving key order.
///
/// Keys are used as labels and values are converted to strings and shown as values.
/// Behavior adapts to whether the view is already inside a `LabeledColumnsLayout`.
/// Empty collections render a localized "empty set" row.
public struct LabeledOrderedDictionaryView<Key: Sendable & Hashable, Value: Sendable>: View {
	public let ordered: OrderedDictionary<Key, Value>
	public let label: String?

	@Environment(\.labeledViewIsInLabeledColumnsLayout) fileprivate var inLayout

	/// Creates a labeled view for an ordered dictionary.
	///
	/// - Parameters:
	///   - ordered: The ordered dictionary to present. Each key becomes a row label.
	///   - label: An optional header label describing the dictionary.
	public init(for ordered: OrderedDictionary<Key, Value>, label: String?) {
		self.ordered = ordered
		self.label = label
	}

	public var body: some View {
		if ordered.isEmpty {
			NilReplacement.emptySet.labeledView(label: label)
		} else {
			if inLayout {
				/// Already inside the column layout - we do not put another Layout.
				if let label {
					"[\(Key.self): \(Value.self)]".labeledView(label: label)
				}
				ForEach(ordered.keys.asArray(), id: \.self) { key in
					"\(ordered[key].orNilString)".labeledView(label: "\(key)")
				}
			} else {
				/// The usual (external) situation - we use ``LabeledViews`` layout.
				LabeledViews {
					if let label {
						"[\(Key.self): \(Value.self)]".labeledView(label: label)
					}
					ForEach(ordered.keys.asArray(), id: \.self) { key in
						"\(ordered[key].orNilString)".labeledView(label: "\(key)")
					}
				}
			}
		}
	}
}

extension OrderedDictionary where Key: Sendable,
								  Key: Hashable,
								  Value: Sendable {
	/// Presents this ordered dictionary as labeled rows, preserving key order.
	///
	/// - Parameter label: An optional header label describing the dictionary.
	/// - Returns: A view that displays the ordered dictionary using `LabeledValueView` rows.
	@MainActor @inlinable public func labeledViews(label: String? = .none) -> some View {
		LabeledOrderedDictionaryView(for: self, label: label)
	}
}

// MARK: - Optional Collection

extension Optional where Wrapped: Collection, Wrapped.Element: Sendable {
	@ViewBuilder @MainActor public func labeledViews(label: String? = .none) -> some View {
		switch self {
		case .none:
			LabeledValueView(String?.none, label: label)
		case .some(let wrapped):
			wrapped.labeledViews(label: label)
		}
	}
}

// MARK: - Optional Ordered

extension Optional {
	@ViewBuilder
	@MainActor public func labeledViews<K, V>(
		label: String? = .none
	) -> some View where Wrapped == OrderedDictionary<K, V>,
						 K: Hashable,
						 K: Sendable,
						 V: Sendable
	{
		switch self {
		case .none:
			LabeledValueView(String?.none, label: label)
		case .some(let wrapped):
			wrapped.labeledViews(label: label)
		}
	}
}

// MARK: String Convertable

public extension CustomStringConvertible {
	@inlinable @MainActor func labeledView(label: String? = nil) -> LabeledValueView {
		LabeledValueView(describing: self, label: label)
	}
}
public extension Optional where Wrapped: CustomStringConvertible {
	@inlinable @MainActor func labeledView(label: String? = nil) -> LabeledValueView {
		LabeledValueView(describing: self, label: label)
	}
}

// MARK: Debug Views

public struct DebugGeometryViewModifier: ViewModifier {
	private let kind: Kind
	private let blurred: Bool
	private let alignment: Alignment
	
	@Environment(\.colorScheme) private var colorScheme: ColorScheme
	
	public init(_ kind: DebugGeometryViewModifier.Kind, blurred: Bool = true, alignment: Alignment = .center) {
		self.kind = kind
		self.blurred = blurred
		self.alignment = alignment
	}
	
	public func body(content: Content) -> some View {
		content
			.apply(when: blurred) { v in
				#if canImport(UIKit)
				v.overlay(
					BlurredBackgroundView(style: .auto(colorScheme))
						.border.cL.wh3()
				)
				#endif
			}
			.overlay(
				GeometryReader {
					self.valueView(of: $0)
						.fixedSize()
						.padding(2)
						.frame(
							maxWidth: $0.size.width,
							maxHeight: $0.size.height,
							alignment: self.alignment
						)
				}
			)
	}
	
	private func valueView(of geometry: GeometryProxy) -> some View {
		switch self.kind {
		case .globalFrame:
			return geometry.frame(in: .global).labeledView()
		case .size:
			return geometry.size.labeledView()
		case .globlPosition:
			return geometry.frame(in: .global).origin.labeledView()
		}
	}
	
	public enum Kind: DefaultCaseFirst {
		case globalFrame
		case globlPosition
		case size
	}
}

/*
struct ShowSizeBlurryVibrantView: View {
	@State private var size: CGSize = .zero
	var body: some View {
		HStack(alignment: .firstTextBaseline, spacing: 2) {
			Text(size.width.wholeValueString)
			Image(systemName: "multiply")
				.font(.system(size: 6, weight: .semibold))
				.opacity(0.4)
				.padding(.bottom, 1)
			Text(size.height.wholeValueString)
		}
		.font(.system(size: 8, weight: .semibold))
		.foregroundStyle(.accentColor)
		.fixedSize()
		.containerSize($size)
		.vibrantOnBlurredBackground()
	}
}
*/

public extension View {
	func debugSize(blurred: Bool = true, _ alignment: Alignment = .center) -> some View {
		modifier(DebugGeometryViewModifier(.size, blurred: blurred, alignment: alignment))
	}
	func debugFrame(blurred: Bool = true, alignment: Alignment = .center) -> some View {
		modifier(DebugGeometryViewModifier(.globalFrame, blurred: blurred, alignment: alignment))
	}
	func debugPosition(blurred: Bool = true, alignment: Alignment = .center) -> some View {
		modifier(DebugGeometryViewModifier(.globlPosition, blurred: blurred, alignment: alignment))
	}
}

/*
// MARK: Previews

#if DEBUG
public struct LabeledValueView_Previews: PreviewProvider {
	static var elements: some View {
		Group {
			Image(systemName: "heart.fill")
				.font(.system(size: 28, weight: .thin))
			
			Image(systemName: "heart.fill")
				.font(.system(size: 100))
			
			Image("tripadvisor")
		}
	}
	
	static let optionalString: String? = "string"
	static let optionalCGFloat: CGFloat? = 134.2
	static let optionalCGSize: CGSize? = CGSize(width: 128, height: 2)
	static let optionalDate: Date? = Date()
	static let optionalBool: Bool? = true
	static let optionalBoolDisplayStyle: LabeledValueView.BoolDisplayStyle? = .default
	static let optionalString2: String? = nil

	public static var previews: some View {
		ForEach(ColorScheme.allCases) { colorScheme in
			Group {
				VStack(alignment: .separator, spacing: 0) {
					Group {
						Group {
							LabeledValueView(CGSize(width: 256, height: 64))
							LabeledValueView(CGSize(width: 128, height: 2), label: "Content size")
							LabeledValueView(256.05)
							LabeledValueView(1920, label: "ScrollView height")
							LabeledValueView(Date(), label: "Now", dateStyle: .short, timeStyle: .short)
						}
						Group {
							LabeledValueView(true, label: "Cool, icon")
							LabeledValueView(false, label: "Shit, icon")
							LabeledValueView(true, label: "Cool, string", boolDisplayStyle: .string)
							LabeledValueView(false, label: "Shit, string", boolDisplayStyle: .string)
							LabeledValueView(true, label: "Cool, int", boolDisplayStyle: .int)
							LabeledValueView(false, label: "Shit, int", boolDisplayStyle: .int)
							LabeledValueView(LabeledValueView.BoolDisplayStyle.icon, label: "Bool display style")
						}
						Group {
							LabeledValueView(optionalString, label: "Opt String")
							LabeledValueView(optionalCGFloat, label: "Opt CGFloat")
							LabeledValueView(optionalCGSize, label: "Opt CGSize")
							LabeledValueView(optionalDate, label: "Opt Date", dateStyle: .short, timeStyle: .short)
							LabeledValueView(optionalBool, label: "Opt bool")
							LabeledValueView(optionalBoolDisplayStyle, label: "Opt BoolDisplayStyle")
							LabeledValueView(optionalString2, label: "nil")
						}
						Group {
							LabeledValueView(describing: [1, 5, [0.2, 0.67]].last, label: "Opt Array")
							CGSize.zero.labeledView()
							Date().labeledView()
							([1, "2"] as [Any]).count.labeledView()
							CGPoint(x: 2, y: 6).labeledView()
							CGRect(x: 0, y: 100, width: 410, height: 800).labeledView()
						}
					}
//					.debugSize()
				}
			}
			.padding()
			.background(Color(uiColor: .systemBackground))
			.previewLayout(.sizeThatFits)
			.environment(\.colorScheme, colorScheme)
		}
	}
}
#endif
*/

