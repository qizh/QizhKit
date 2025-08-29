//
//  LabeledValueView.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 28.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Environment Value

extension EnvironmentValues {
	@Entry public var labeledViewLengthLimit: Int = 50
	@Entry public var labeledViewMaxValueWidth: CGFloat? = 256
	@Entry public var labeledViewAllowMultiline: Bool = false
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
	
	public func setLabeledView(allowMultiline: Bool) -> some View {
		environment(\.labeledViewAllowMultiline, allowMultiline)
	}
	
	public func setLabeledView(maxValueWidth: CGFloat?) -> some View {
		environment(\.labeledViewMaxValueWidth, maxValueWidth)
	}
}

// MARK: Stack

public struct LabeledViews<Views: View>: View {
	public let views: Views
	
	public init(@ViewBuilder _ views: () -> Views) {
		self.views = views()
	}
	
	public var body: some View {
		VStack(alignment: .separator, spacing: 2) {
			views
		}
		.containerRelativeFrame(.horizontal)
	}
}

/*
extension VStack {
	@MainActor
	public static func LabeledViews(@ViewBuilder _ content: () -> Content) -> some View {
		VStack(alignment: .separator, spacing: 2, content: content)
			.containerRelativeFrame(.horizontal)
			/*
			.containerRelativeFrame(
				.horizontal,
				count: <#T##Int#>,
				span: <#T##Int#>,
				spacing: <#T##CGFloat#>,
				alignment: <#T##Alignment#>
			)
			*/
		/*
		LazyVStack(alignment: .separator, spacing: 2) {
			content()
		}
		*/
			// .fixedSize()
		// .alignmentGuide(.separator, computeValue: \.width.half) // { $0[.center] }
	}
}

extension LazyVStack {
	@MainActor
	public static func LabeledViews(@ViewBuilder _ content: () -> Content) -> some View {
		LazyVStack(alignment: .separator, spacing: 2, content: content)
			.containerRelativeFrame(.horizontal)
	}
}
*/

/*
// MARK: Library Content

public struct LabeledValueLibraryContent: LibraryContentProvider {
	@LibraryContentBuilder
	public var views: [LibraryItem] {
		LibraryItem(
			LabeledViews {
				"Value".labeledView(label: "Label")
			},
			visible: true,
			title: "Stack of labeled views",
			category: .layout,
			matchingSignature: "VStack.LabeledViews"
		)
	}
}
*/

// MARK: View

public struct LabeledValueView: View {
	fileprivate var valueView: ValueView
	fileprivate var label: String?
	
	@Environment(\.colorScheme) fileprivate var colorScheme
	@Environment(\.pixelLength) fileprivate var pixelLength
	@Environment(\.labeledViewAllowMultiline) fileprivate var allowMultiline
	@Environment(\.labeledViewMaxValueWidth) fileprivate var maxValueWidth
	
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
	
	/*
	fileprivate struct ValueView: View {
		fileprivate let value: String
		@Environment(\.labeledViewLengthLimit) fileprivate var lengthLimit
		@Environment(\.labeledViewAllowMultiline) fileprivate var allowMultiline
		
		internal init <S: StringProtocol> (for value: S) {
			self.value = String(value)
		}
		
		var body: some View {
			Text(value)
				.semibold(8)
				.padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
				.foregroundStyle(.primary)
		}
	}
	*/
	
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
			/*
			self.init(
				valueView: AnyView(
					(
						Text("(").foregroundStyle(.secondary) +
						Text(String(format: "%.\(fractionDigits)f", wrapped.origin.x)) +
						Text(", ").foregroundStyle(.secondary) +
						Text(String(format: "%.\(fractionDigits)f", wrapped.origin.y)) +
						Text("), (").foregroundStyle(.secondary) +
						Text(String(format: "%.\(fractionDigits)f", wrapped.size.width)) +
						Text(" x ").foregroundStyle(.secondary) +
						Text(String(format: "%.\(fractionDigits)f", wrapped.size.height)) +
						Text(")").foregroundStyle(.secondary)
					)
					.font(.system(size: 8, weight: .semibold))
					.padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
					.foregroundStyle(.primary)
				),
				label: label
			)
			*/
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
			/*
			self.init(
				valueView: AnyView(
					(
						Text(String(format: "%.\(fractionDigits)f", wrapped.x)) +
						Text(", ").foregroundStyle(.secondary) +
						Text(String(format: "%.\(fractionDigits)f", wrapped.y))
					)
					.font(.system(size: 8, weight: .semibold))
					.padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
					.foregroundStyle(.primary)
				),
				label: label
			)
			*/
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
			/*
			self.init(
				valueView: AnyView(
					(
						Text(String(format: "%.\(fractionDigits)f", wrapped.dx)) +
						Text(", ").foregroundStyle(.secondary) +
						Text(String(format: "%.\(fractionDigits)f", wrapped.dy))
					)
					.font(.system(size: 8, weight: .semibold))
					.padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
					.foregroundStyle(.primary)
				),
				label: label
			)
			*/
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
			/*
			self.init(
				valueView: AnyView(
					HStack(alignment: .firstTextBaseline, spacing: 2) {
						Text(String(format: "%.\(fractionDigits)f", wrapped.width))
						Image(systemName: "multiply")
							.foregroundStyle(.secondary)
							.font(.system(size: 6, weight: .semibold))
							.padding(.bottom, 1)
						Text(String(format: "%.\(fractionDigits)f", wrapped.height))
					}
					.font(.system(size: 8, weight: .semibold))
					.padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
					.foregroundStyle(.primary)
				),
				label: label
			)
			*/
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
			/*
			self.init(
				valueView: AnyView(
					HStack(alignment: .firstTextBaseline, spacing: 2) {
						Text("top:")
							.foregroundStyle(.secondaryLabel)
						Text(String(format: "%.\(fractionDigits)f", wrapped.top))
						Text("bottom:")
							.foregroundStyle(.secondaryLabel)
						Text(String(format: "%.\(fractionDigits)f", wrapped.bottom))
						Text("left:")
							.foregroundStyle(.secondaryLabel)
						Text(String(format: "%.\(fractionDigits)f", wrapped.left))
						Text("right:")
							.foregroundStyle(.secondaryLabel)
						Text(String(format: "%.\(fractionDigits)f", wrapped.right))
					}
					.font(.system(size: 8, weight: .semibold))
					.padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
					.foregroundStyle(Color(uiColor: .label))
				),
				label: label
			)
			*/
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
			/*
			self.init(
				valueView: AnyView(
					HStack(alignment: .firstTextBaseline, spacing: 2) {
						Text("top:").foregroundStyle(.secondary)
						Text(String(format: "%.\(fractionDigits)f", wrapped.top))
						Text("bot:").foregroundStyle(.secondary)
						Text(String(format: "%.\(fractionDigits)f", wrapped.bottom))
						Text("lead:").foregroundStyle(.secondary)
						Text(String(format: "%.\(fractionDigits)f", wrapped.leading))
						Text("trail:").foregroundStyle(.secondary)
						Text(String(format: "%.\(fractionDigits)f", wrapped.trailing))
					}
					.font(.system(size: 8, weight: .semibold))
					.padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
					.foregroundStyle(.primary)
				),
				label: label
			)
			*/
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
	
	/*
	public init<EnumValue: CaseNameProvidable>(
		_ value: EnumValue?,
		label: String? = nil
	) {
		switch value {
		case .none:
			self.init("nil", label: label)
		case .some(let wrapped):
			self.init(".\(wrapped.caseName)", label: label)
		}
	}
	*/
	
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
					.horizontal,
					alignment: .trailing
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
				}
				.draggable(valueView.transferableText)
				.containerRelativeFrame(
					.horizontal,
					alignment: .leading
				) { length, axis in
					switch axis {
					case .horizontal: (length - spacing) * valueRatio
					case .vertical where allowMultiline: length
					case .vertical: 15
					}
				}
		}
		// .containerValue(<#T##keyPath: WritableKeyPath<ContainerValues, V>##WritableKeyPath<ContainerValues, V>#>, <#T##value: V##V#>)
		.compositingGroup()
		.shadow(
			color: colorScheme.isDark ? .clear : .black.opacity(0.4),
			radius: 2
		)
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
	
	public enum BoolDisplayStyle: DefaultCaseFirst, EasyCaseComparable {
		case icon
		case string
		case int
		case emoji
	}
}

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
			.fixedHeight(isMultiline)
			.alignmentGuide(.separator) { $0[.leading] }
			.button {
				withAnimation(.bouncy) {
					isSwitched.toggle()
				}
			}
			.buttonStyle(.plain)
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
	
	/*
	@inlinable @MainActor func labeledView(label: String? = nil) -> LabeledValueView {
		LabeledValueView(self, label: label)
	}
	*/
}
public extension Optional where Wrapped: EasySelfComparable {
	@inlinable @MainActor func caseView(label: String? = nil) -> LabeledValueView {
		LabeledValueView(self, label: label)
	}
	
	/*
	@inlinable @MainActor func labeledView(label: String? = nil) -> LabeledValueView {
		LabeledValueView(self, label: label)
	}
	*/
}
public extension Binding where Value: EasySelfComparable {
	@inlinable @MainActor func caseView(label: String? = nil) -> LabeledValueView {
		LabeledValueView(self.wrappedValue, label: label)
	}
	
	/*
	@inlinable func labeledView(label: String? = nil) -> LabeledValueView {
		LabeledValueView(self.wrappedValue, label: label)
	}
	*/
}

// MARK: Collection

extension Collection where Element: Sendable {
	@ViewBuilder @MainActor public func labeledViews(label: String? = nil) -> some View {
		if isEmpty {
			NilReplacement.emptySet.labeledView(label: label)
		} else {
			LabeledViews {
				if let label {
					"[\(Element.self)]".labeledView(label: label)
				}
				ForEach(enumerating: self) { offset, element in
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

// MARK: Dictionary

extension Dictionary where Key: Sendable, Value: Sendable {
	@ViewBuilder @MainActor public func labeledViews(label: String? = nil) -> some View {
		if isEmpty {
			NilReplacement.emptySet.labeledView(label: label)
		} else {
			LabeledViews {
				if let label {
					"[\(Key.self): \(Value.self)]".labeledView(label: label)
				}
				ForEach(enumerating: self) { offset, element in
					"\(element.value)".labeledView(label: "\(element.key)")
				}
			}
		}
	}
}

// MARK: Set

extension Set where Element: Sendable {
	@ViewBuilder @MainActor public func labeledViews(label: String? = .none) -> some View {
		if isEmpty {
			NilReplacement.emptySet.labeledView(label: label)
		} else {
			LabeledViews {
				if let label {
					"[\(Element.self)]".labeledView(label: label)
				}
				ForEach(enumerating: self) { offset, element in
					"\(element)".labeledView(label: "\(offset)")
				}
			}
		}
	}
}

// MARK: - Ordered Collections

import OrderedCollections

// MARK: OrderedDictionary

extension OrderedDictionary {
	@ViewBuilder @MainActor public func labeledViews(label: String? = .none) -> some View {
		if isEmpty {
			NilReplacement.emptySet.labeledView(label: label)
		} else {
			LabeledViews {
				if let label {
					"[\(Key.self): \(Value.self)]".labeledView(label: label)
				}
				ForEach(self.keys.asArray(), id: \.self) { key in
					"\(self[key].orNilString)".labeledView(label: "\(key)")
					/*
					let value = "\(self[key].orNilString)"
					value
						.labeledView(label: "\(key)")
						.layoutPriority(value.count.double)
					*/
				}
			}
		}
	}
}

// MARK: - Optional Collection

extension Optional where Wrapped: Collection, Wrapped.Element: Sendable { //, Wrapped: Hashable, Wrapped.Element: Hashable {
	@ViewBuilder @MainActor public func labeledViews(label: String? = .none) -> some View {
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
