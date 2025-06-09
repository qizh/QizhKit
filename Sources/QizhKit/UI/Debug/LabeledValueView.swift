//
//  LabeledValueView.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 28.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Environment Value

public struct LabeledViewLengthLimitKey: EnvironmentKey {
	public static let defaultValue: Int = 50
}

extension EnvironmentValues {
	public var labeledViewLengthLimit: Int {
		get { self[LabeledViewLengthLimitKey.self] }
		set { self[LabeledViewLengthLimitKey.self] = newValue }
	}
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
	public func labeledViewLengthLimit(_ length: Int) -> some View {
		environment(\.labeledViewLengthLimit, length)
	}
}

// MARK: Stack

public extension VStack {
	@inlinable static func LabeledViews(@ViewBuilder _ content: () -> Content) -> VStack {
		.init(alignment: .separator, spacing: 2, content: content)
	}
}

/*
// MARK: Library Content

public struct LabeledValueLibraryContent: LibraryContentProvider {
	@LibraryContentBuilder
	public var views: [LibraryItem] {
		LibraryItem(
			VStack.LabeledViews {
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
	private var valueView: AnyView
	private var label: String?
	
	@Environment(\.colorScheme) private var colorScheme
	
	private func prepare(_ label: String?) -> String? {
		label.map(\.withLinesNSpacesTrimmed)
			.map { String($0.prefix(30)) }
			.flatMap(\.nonEmpty)
	}
	
	private init(
		valueView: AnyView,
		label: String?
	) {
		self.valueView = valueView
		self.label = prepare(label)
	}
	
	public init <S: StringProtocol> (
		_ value: S?,
		label: String? = nil
	) {
		switch value {
		case .none:
			self.init(valueView: Self.bool(value: false).asAnyView(), label: label)
		case .some(let wrapped):
			self.init(
				valueView: ValueView(for: wrapped).asAnyView(),
				label: label
			)
		}
	}
	
	fileprivate struct ValueView: View {
		private let value: String
		@Environment(\.labeledViewLengthLimit) private var lengthLimit
		
		internal init <S: StringProtocol> (for value: S) {
			self.value = String(value)
		}
		
		var body: some View {
			Text(value.prefix(lengthLimit))
				.semibold(8)
				.padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
				.foregroundLabel()
		}
	}
	
	public init(
		_ value: CGFloat?,
		label: String? = nil,
		fractionDigits: UInt = 0
	) {
		switch value {
		case .none:
			self.init(valueView: Self.bool(value: false).asAnyView(), label: label)
		case .some(let wrapped):
			self.init(String(format: "%.\(fractionDigits)f", wrapped), label: label)
		}
	}
	
	public init <F: BinaryInteger> (
		 _ value: F?,
		   label: String? = .none
	) {
		switch value {
		case .none: self.init(valueView: Self.bool(value: false).asAnyView(), label: label)
		case .some(let wrapped): self.init("\(wrapped)", label: label)
		}
	}
	
	public init <F: BinaryFloatingPoint & CVarArg> (
		 _ value: F?,
		   label: String? = .none,
		fraction: Int     = .zero
	) {
		switch value {
		case .none: self.init(valueView: Self.bool(value: false).asAnyView(), label: label)
		case .some(let wrapped): self.init("\(wrapped, f: fraction)", label: label)
		}
	}

	public init(
		_ value: CGRect?,
		label: String? = nil,
		fractionDigits: UInt = 0
	) {
		switch value {
		case .none:
			self.init(valueView: Self.bool(value: false).asAnyView(), label: label)
		case .some(let wrapped):
			self.init(
				valueView: AnyView(
					(
						Text("(").foregroundStyle(.secondaryLabel) +
						Text(String(format: "%.\(fractionDigits)f", wrapped.origin.x)) +
						Text(", ").foregroundStyle(.secondaryLabel) +
						Text(String(format: "%.\(fractionDigits)f", wrapped.origin.y)) +
						Text("), (").foregroundStyle(.secondaryLabel) +
						Text(String(format: "%.\(fractionDigits)f", wrapped.size.width)) +
						Text(" x ").foregroundStyle(.secondaryLabel) +
						Text(String(format: "%.\(fractionDigits)f", wrapped.size.height)) +
						Text(")").foregroundStyle(.secondaryLabel)
					)
					.font(.system(size: 8, weight: .semibold))
					.padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
					.foregroundStyle(Color(uiColor: .label))
				),
				label: label
			)
		}
	}
	
	public init(
		_ value: CGPoint?,
		label: String? = nil,
		fractionDigits: UInt = 0
	) {
		switch value {
		case .none:
			self.init(valueView: Self.bool(value: false).asAnyView(), label: label)
		case .some(let wrapped):
			self.init(
				valueView: AnyView(
					(
						Text(String(format: "%.\(fractionDigits)f", wrapped.x)) +
						Text(", ").foregroundStyle(.secondaryLabel) +
						Text(String(format: "%.\(fractionDigits)f", wrapped.y))
					)
					.font(.system(size: 8, weight: .semibold))
					.padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
					.foregroundStyle(Color(uiColor: .label))
				),
				label: label
			)
		}
	}
	
	public init(
		_ value: CGVector?,
		label: String? = nil,
		fractionDigits: UInt = 0
	) {
		switch value {
		case .none:
			self.init(valueView: Self.bool(value: false).asAnyView(), label: label)
		case .some(let wrapped):
			self.init(
				valueView: AnyView(
					(
						Text(String(format: "%.\(fractionDigits)f", wrapped.dx)) +
						Text(", ").foregroundStyle(.secondaryLabel) +
						Text(String(format: "%.\(fractionDigits)f", wrapped.dy))
					)
					.font(.system(size: 8, weight: .semibold))
					.padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
					.foregroundStyle(.label)
				),
				label: label
			)
		}
	}
	
	public init(
		_ value: CGSize?,
		label: String? = nil,
		fractionDigits: UInt = 0
	) {
		switch value {
		case .none:
			self.init(valueView: Self.bool(value: false).asAnyView(), label: label)
		case .some(let wrapped):
			self.init(
				valueView: AnyView(
					HStack(alignment: .firstTextBaseline, spacing: 2) {
						Text(String(format: "%.\(fractionDigits)f", wrapped.width))
						Image(systemName: "multiply")
							.foregroundStyle(.secondaryLabel)
							.font(.system(size: 6, weight: .semibold))
							.padding(.bottom, 1)
						Text(String(format: "%.\(fractionDigits)f", wrapped.height))
					}
					.font(.system(size: 8, weight: .semibold))
					.padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
					.foregroundStyle(.label)
				),
				label: label
			)
		}
	}
	
	public init(
		_ value: UIEdgeInsets?,
		label: String? = nil,
		fractionDigits: UInt = 0
	) {
		switch value {
		case .none:
			self.init(valueView: Self.bool(value: false).asAnyView(), label: label)
		case .some(let wrapped):
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
		}
	}
	
	public init(
		_ value: EdgeInsets?,
		label: String? = nil,
		fractionDigits: UInt = 0
	) {
		switch value {
		case .none:
			self.init(valueView: Self.bool(value: false).asAnyView(), label: label)
		case .some(let wrapped):
			self.init(
				valueView: AnyView(
					HStack(alignment: .firstTextBaseline, spacing: 2) {
						Text("top:")
							.foregroundStyle(.secondaryLabel)
						Text(String(format: "%.\(fractionDigits)f", wrapped.top))
						Text("bot:")
							.foregroundStyle(.secondaryLabel)
						Text(String(format: "%.\(fractionDigits)f", wrapped.bottom))
						Text("lead:")
							.foregroundStyle(.secondaryLabel)
						Text(String(format: "%.\(fractionDigits)f", wrapped.leading))
						Text("trail:")
							.foregroundStyle(.secondaryLabel)
						Text(String(format: "%.\(fractionDigits)f", wrapped.trailing))
					}
					.font(.system(size: 8, weight: .semibold))
					.padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
					.foregroundStyle(Color(uiColor: .label))
				),
				label: label
			)
		}
	}
	
	public init(
		_ value: Date?,
		label: String? = nil,
		dateStyle: DateFormatter.Style = .short,
		timeStyle: DateFormatter.Style = .short,
		timeZone: TimeZone = .autoupdatingCurrent,
		locale: Locale = .autoupdatingCurrent
	) {
		switch value {
		case .none:
			self.init(valueView: Self.bool(value: false).asAnyView(), label: label)
		case .some(let wrapped):
			let formatter = DateFormatter()
			formatter.dateStyle = dateStyle
			formatter.timeStyle = timeStyle
			formatter.timeZone = timeZone
			formatter.locale = locale
			
			self.init(
				formatter.string(from: wrapped),
				label: label
			)
		}
	}
	
	public init(
		_ value: Bool?,
		label: String? = nil,
		boolDisplayStyle style: BoolDisplayStyle = .default
	) {
		switch value {
		case .none:
			self.init(valueView: Self.bool(value: false).asAnyView(), label: label)
		case .some(let wrapped):
			switch style {
			case .string:
				self.init(wrapped ? "true" : "false", label: label)
			case .int:
				self.init(wrapped ? "1" : "0", label: label)
			case .icon:
				self.init(valueView: Self.bool(value: wrapped).asAnyView(), label: label)
			case .emoji:
				self.init(String(wrapped.sign), label: label)
			}
		}
	}
	
	static private func bool(value: Bool) -> some View {
		Image.bool(value)
			.semibold(8)
			.padding(.horizontal, 5)
			.foregroundLabel()
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
		case .none:
			self.init(valueView: Self.bool(value: false).asAnyView(), label: label)
		case .some(let wrapped):
			self.init(".\(caseName(of: wrapped, [.name, .arguments]))", label: label)
		}
	}
	
	public init(
		describing value: CustomStringConvertible?,
		label: String? = nil
	) {
		switch value {
		case .none:
			self.init(valueView: Self.bool(value: false).asAnyView(), label: label)
		case .some(let wrapped):
			self.init(String(describing: wrapped), label: label)
		}
	}
	
	public var body: some View {
		HStack(alignment: .center, spacing: colorScheme.isDark ? 0 : 1/3) {
			Group {
				label.mapText()
					.font(Font.system(size: 10, weight: .semibold).smallCaps())
					.padding(EdgeInsets(top: 1, leading: 5, bottom: 2, trailing: 5))
					.foregroundStyle(Color(uiColor: .secondaryLabel))
				
				valueView
					.alignmentGuide(.separator) { $0[.leading] }
			}
			.lineLimit(1)
			.background(Color(uiColor: .systemBackground).opacity(0.8))
			.roundedBorder(
				Color(.label).opacity(0.6),
				radius: 2,
				weight: colorScheme.isDark ? 1/3 : 0
			)
//			.fixedSize(horizontal: true, vertical: false)
		}
		.frame(height: 15)
		.background(background)
	}
	
	@ViewBuilder private var background: some View {
		if colorScheme.isDark {
			EmptyView()
		} else {
			Color.label.opacity(0.4)
				.blur(radius: 2)
		}
	}
	
	public enum BoolDisplayStyle: DefaultCaseFirst, EasyCaseComparable {
		case icon
		case string
		case int
		case emoji
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

public extension BinaryInteger {
	@inlinable @MainActor func labeledView(label: String? = .none) -> LabeledValueView {
		LabeledValueView(self, label: label)
	}
}

public extension Optional where Wrapped: BinaryInteger {
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
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: UInt) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: UInt = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}
public extension Optional where Wrapped == CGSize {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: UInt) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: UInt = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}

public extension CGPoint {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: UInt) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: UInt = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}
public extension Optional where Wrapped == CGPoint {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: UInt) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: UInt = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}

// MARK: ┣ CGVector

public extension CGVector {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: UInt) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
}
public extension Optional<CGVector> {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: UInt) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
}

// MARK: ┣ CGRect

public extension CGRect {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: UInt) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: UInt = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}
public extension Optional where Wrapped == CGRect {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: UInt) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: UInt = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}

public extension UIEdgeInsets {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: UInt) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: UInt = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}
public extension Optional where Wrapped == UIEdgeInsets {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: UInt) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: UInt = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}

public extension EdgeInsets {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: UInt) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: UInt = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}
public extension Optional where Wrapped == EdgeInsets {
	@inlinable @MainActor func labeledView(label: String? = nil, f digits: UInt) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: digits)
	}
	@inlinable @MainActor func labeledView(label: String? = nil, fractionDigits: UInt = 0) -> LabeledValueView {
		LabeledValueView(self, label: label, fractionDigits: fractionDigits)
	}
}

public extension Date {
	@inlinable @MainActor func labeledView(
		label: String? = nil,
		dateStyle: DateFormatter.Style = .short,
		timeStyle: DateFormatter.Style = .short,
		timeZone: TimeZone = .autoupdatingCurrent,
		locale: Locale = .autoupdatingCurrent
	) -> LabeledValueView {
		LabeledValueView(
			self,
			label: label,
			dateStyle: dateStyle,
			timeStyle: timeStyle,
			timeZone: timeZone,
			locale: locale
		)
	}
}
public extension Optional where Wrapped == Date {
	@inlinable @MainActor func labeledView(
		label: String? = nil,
		dateStyle: DateFormatter.Style = .short,
		timeStyle: DateFormatter.Style = .short,
		timeZone: TimeZone = .autoupdatingCurrent,
		locale: Locale = .autoupdatingCurrent
	) -> LabeledValueView {
		LabeledValueView(
			self,
			label: label,
			dateStyle: dateStyle,
			timeStyle: timeStyle,
			timeZone: timeZone,
			locale: locale
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

extension Collection {
	@ViewBuilder @MainActor public func labeledViews(label: String? = nil) -> some View {
		if isEmpty {
			NilReplacement.emptySet.labeledView(label: label)
		} else {
			VStack.LabeledViews {
				"[\(Element.self)]".labeledView(label: label)
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

extension Dictionary {
	@ViewBuilder @MainActor public func labeledViews(label: String? = nil) -> some View {
		if isEmpty {
			NilReplacement.emptySet.labeledView(label: label)
		} else {
			VStack.LabeledViews {
				"[\(Key.self): \(Value.self)]".labeledView(label: label)
				ForEach(enumerating: self) { offset, element in
					"\(element.value)".labeledView(label: "\(element.key)")
				}
			}
		}
	}
}

// MARK: Set

extension Set {
	@ViewBuilder @MainActor public func labeledViews(label: String? = .none) -> some View {
		if isEmpty {
			NilReplacement.emptySet.labeledView(label: label)
		} else {
			VStack.LabeledViews {
				"[\(Element.self)]".labeledView(label: label)
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
			VStack.LabeledViews {
				"[\(Key.self): \(Value.self)]".labeledView(label: label)
				ForEach(self.keys.asArray(), id: \.self) { key in
					"\(self[key].orNilString)".labeledView(label: "\(key)")
				}
			}
		}
	}
}

// MARK: - Optional Collection

extension Optional where Wrapped: Collection { //, Wrapped: Hashable, Wrapped.Element: Hashable {
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
			.apply(when: blurred) { v in v
				.overlay(
					BlurredBackgroundView(style: .auto(colorScheme))
						.border.cL.wh3()
				)
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
