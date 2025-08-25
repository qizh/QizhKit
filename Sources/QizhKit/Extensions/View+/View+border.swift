//
//  View+border.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 23.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct BorderCrafterValues {
	
	// MARK: Weight
	
	public struct Weights: Sendable {
		public typealias Value = CGFloat
		public typealias Key = KeyPath<Self, Value>
		private init() {}
		private static let instance: Self = .init()
		public static func value(for key: Key) -> Value {
			instance[keyPath: key]
		}
		
		/// width: 1/3
		public let wh3 : Value = 1/3
		/// width: 1/2
		public let wh2 : Value = 1/2
		/// width: 1
		public let w1  : Value = 1
		/// width: 1.5
		public let w15 : Value = 1.5
		/// width: 2
		public let w2  : Value = 2
		/// width: 2.5
		public let w25 : Value = 2.5
		/// width: 3
		public let w3  : Value = 3
		/// width: 3.5
		public let w35 : Value = 3.5
		/// width: 4
		public let w4  : Value = 4
		/// width: 4.5
		public let w45 : Value = 4.5
		/// width: 5
		public let w5  : Value = 5
		/// width: 5.5
		public let w55 : Value = 5.5
		/// width: 6
		public let w6  : Value = 6
		/// width: 6.5
		public let w65 : Value = 6.5
		/// width: 7
		public let w7  : Value = 7
		/// width: 7.5
		public let w75 : Value = 7.5
		/// width: 8
		public let w8  : Value = 8
		/// width: 8.5
		public let w85 : Value = 8.5
		/// width: 9
		public let w9  : Value = 9
		/// width: 9.5
		public let w95 : Value = 9.5
		/// width: 10
		public let w10 : Value = 10
		/// width: 16
		public let w16 : Value = 10
	}
	
	// MARK: Opacities
	
	public struct Opacities: Sendable {
		public typealias Value = Double
		public typealias Key = KeyPath<Self, Value>
		private init() {}
		private static let instance: Self = .init()
		public static func value(for key: Key) -> Value {
			instance[keyPath: key]
		}

		/// Transparent
		public let oo   : Value = 0
		/// Transparent
		public let o0   : Value = 0
		/// .opacity(0.1)
		public let o1   : Value = 0.1
		/// .opacity(0.2)
		public let o2   : Value = 0.2
		/// .opacity(0.3)
		public let o3   : Value = 0.3
		/// .opacity(0.4)
		public let o4   : Value = 0.4
		/// .opacity(0.5)
		public let o5   : Value = 0.5
		/// .opacity(0.6)
		public let o6   : Value = 0.6
		/// .opacity(0.7)
		public let o7   : Value = 0.7
		/// .opacity(0.8)
		public let o8   : Value = 0.8
		/// .opacity(0.9)
		public let o9   : Value = 0.9
		/// .opacity(0.05)
		public let o05  : Value = 0.05
		/// .opacity(0.10)
		public let o10  : Value = 0.10
		/// .opacity(0.15)
		public let o15  : Value = 0.15
		/// .opacity(0.20)
		public let o20  : Value = 0.20
		/// .opacity(0.25)
		public let o25  : Value = 0.25
		/// .opacity(0.30)
		public let o30  : Value = 0.30
		/// .opacity(0.35)
		public let o35  : Value = 0.35
		/// .opacity(0.40)
		public let o40  : Value = 0.40
		/// .opacity(0.45)
		public let o45  : Value = 0.45
		/// .opacity(0.50)
		public let o50  : Value = 0.50
		/// .opacity(0.55)
		public let o55  : Value = 0.55
		/// .opacity(0.60)
		public let o60  : Value = 0.60
		/// .opacity(0.65)
		public let o65  : Value = 0.65
		/// .opacity(0.70)
		public let o70  : Value = 0.70
		/// .opacity(0.75)
		public let o75  : Value = 0.75
		/// .opacity(0.80)
		public let o80  : Value = 0.80
		/// .opacity(0.85)
		public let o85  : Value = 0.85
		/// .opacity(0.90)
		public let o90  : Value = 0.90
		/// .opacity(0.95)
		public let o95  : Value = 0.95
		/// Solid
		public let o100 : Value = 1
		/// Solid
		public let o    : Value = 1
	}
	
	// MARK: Colors
	
	public struct Colors: Sendable {
		public typealias Value = Color
		public typealias Key = KeyPath<Self, Value>
		private init() {}
		private static let instance: Self = .init()
		public static func value(for key: Key) -> Value {
			instance[keyPath: key]
		}
		
		/// Color.black
		public let c0  : Value = .black
		/// Color.blue
		public let c1  : Value = .blue
		/// Color.pink
		public let c2  : Value = .pink
		/// Color.green
		public let c3  : Value = .green
		/// Color.orange
		public let c4  : Value = .orange
		/// Color.gray
		public let c5  : Value = .gray
		/// Color.purple
		public let c6  : Value = .purple
		/// Color.yellow
		public let c7  : Value = .yellow
		/// Color.red
		public let c8  : Value = .red
		
		/// Color(uiColor: .cyan)
		public let c9  : Value = Value(.cyan)
		/// Color(uiColor: .magenta)
		public let c10 : Value = Value(.magenta)
		/// Color(uiColor: .brown)
		public let c11 : Value = Value(.brown)
		
		/// Color(uiColor: .systemGray)
		public let cg  : Value = Value(.systemGray)
		
		#if canImport(UIKit)
		/// Color(uiColor: .systemGray2)
		public let cg2 : Value = Value(.systemGray2)
		/// Color(uiColor: .systemGray3)
		public let cg3 : Value = Value(.systemGray3)
		/// Color(uiColor: .systemGray4)
		public let cg4 : Value = Value(.systemGray4)
		/// Color(uiColor: .systemGray5)
		public let cg5 : Value = Value(.systemGray5)
		/// Color(uiColor: .systemGray6)
		public let cg6 : Value = Value(.systemGray6)
		
		/// Color(uiColor: .label)
		public let cL  : Value = Value(.label)
		/// Color(uiColor: .secondaryLabel)
		public let cSL : Value = Value(.secondaryLabel)
		/// Color(uiColor: .systemBackground)
		public let cB  : Value = Value(.systemBackground)
		/// Color(uiColor: .secondarySystemBackground)
		public let cSB : Value = Value(.secondarySystemBackground)
		#endif
	}
	
	#if canImport(UIKit)
	public struct UIColors: Sendable {
		public typealias Value = UIColor
		public typealias Key = KeyPath<Self, Value>
		private init() {}
		private static let instance: Self = .init()
		public static func value(for key: Key) -> Value {
			instance[keyPath: key]
		}
		
		public let systemRed                        : Value = .systemRed
		public let systemGreen                      : Value = .systemGreen
		public let systemBlue                       : Value = .systemBlue
		public let systemOrange                     : Value = .systemOrange
		public let systemYellow                     : Value = .systemYellow
		public let systemPink                       : Value = .systemPink
		public let systemPurple                     : Value = .systemPurple
		public let systemTeal                       : Value = .systemTeal
		public let systemIndigo                     : Value = .systemIndigo
		public let systemGray                       : Value = .systemGray
		public let systemGray2                      : Value = .systemGray2
		public let systemGray3                      : Value = .systemGray3
		public let systemGray4                      : Value = .systemGray4
		public let systemGray5                      : Value = .systemGray5
		public let systemGray6                      : Value = .systemGray6
		public let label                            : Value = .label
		public let secondaryLabel                   : Value = .secondaryLabel
		public let tertiaryLabel                    : Value = .tertiaryLabel
		public let quaternaryLabel                  : Value = .quaternaryLabel
		public let link                             : Value = .link
		public let placeholderText                  : Value = .placeholderText
		public let separator                        : Value = .separator
		public let opaqueSeparator                  : Value = .opaqueSeparator
		public let systemBackground                 : Value = .systemBackground
		public let secondarySystemBackground        : Value = .secondarySystemBackground
		public let tertiarySystemBackground         : Value = .tertiarySystemBackground
		public let systemGroupedBackground          : Value = .systemGroupedBackground
		public let secondarySystemGroupedBackground : Value = .secondarySystemGroupedBackground
		public let tertiarySystemGroupedBackground  : Value = .tertiarySystemGroupedBackground
		public let systemFill                       : Value = .systemFill
		public let secondarySystemFill              : Value = .secondarySystemFill
		public let tertiarySystemFill               : Value = .tertiarySystemFill
		public let quaternarySystemFill             : Value = .quaternarySystemFill
		public let lightText                        : Value = .lightText
		public let darkText                         : Value = .darkText
		public let black                            : Value = .black
		public let darkGray                         : Value = .darkGray
		public let lightGray                        : Value = .lightGray
		public let white                            : Value = .white
		public let gray                             : Value = .gray
		public let red                              : Value = .red
		public let green                            : Value = .green
		public let blue                             : Value = .blue
		public let cyan                             : Value = .cyan
		public let yellow                           : Value = .yellow
		public let magenta                          : Value = .magenta
		public let orange                           : Value = .orange
		public let purple                           : Value = .purple
		public let brown                            : Value = .brown
		public let clear                            : Value = .clear
	}
	#endif
}

// MARK: Crafter

@dynamicMemberLookup
public struct BorderCrafter <Source : View> : Updatable {
	public typealias Colors    = BorderCrafterValues.Colors
	#if canImport(UIKit)
	public typealias UIColors  = BorderCrafterValues.UIColors
	#endif
	public typealias Opacities = BorderCrafterValues.Opacities
	public typealias Weights   = BorderCrafterValues.Weights

	private var color   : Colors    .Value = Colors    .value(for: \.c1)
	private var opacity : Opacities .Value = Opacities .value(for: \.o4)
	private var weight  : Weights   .Value = Weights   .value(for: \.w1)
	
	private let source: Source
	
	public init(_ source: Source) {
		self.source = source
	}
	
	public func callAsFunction() -> some View {
		source.border(
			color.opacity(opacity),
			width: weight
		)
	}
	
	// MARK: Lookup
	
	public subscript(dynamicMember key: Colors.Key) -> Self {
		updating(\.color)
			.with(Colors.value(for: key))
	}
	
	#if canImport(UIKit)
	public subscript(dynamicMember key: UIColors.Key) -> Self {
		updating(\.color)
			.with(Color(uiColor: UIColors.value(for: key)))
	}
	#endif
	
	public subscript(dynamicMember key: Opacities.Key) -> Self {
		updating(\.opacity)
			.with(Opacities.value(for: key))
	}
	
	public subscript(dynamicMember key: Weights.Key) -> Self {
		updating(\.weight)
			.with(Weights.value(for: key))
	}
	
	// MARK: Set
	
	public func color(_ value: Colors.Value) -> Self {
		updating(\.color)
			.with(value)
	}
	
	#if canImport(UIKit)
	public func uiColor(_ value: UIColors.Value) -> Self {
		updating(\.color)
			.with(Color(uiColor: value))
	}
	#endif
	
	public func opacity(_ value: Opacities.Value) -> Self {
		updating(\.opacity)
			.with(value)
	}
	
	public func weight(_ value: Weights.Value) -> Self {
		updating(\.weight)
			.with(value)
	}
}

// MARK: Modifier

public extension View {
	@inlinable @MainActor func borderColor(_ color: Color, weight: CGFloat) -> some View {
		border(color, width: weight)
	}
	
	@inlinable @MainActor var border: BorderCrafter<Self> {
		.init(self)
	}
}
