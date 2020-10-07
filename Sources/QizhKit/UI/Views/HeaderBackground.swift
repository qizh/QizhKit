//
//  HeaderBackground.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 24.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import Combine

public struct ShowHeaderBackgroundViewModifier: ViewModifier {
	private let height: CGFloat
	private let customStyle: UIBlurEffect.Style?
	private let measureType: MeasureType
	
	private let show: Bool
	private let debug: Bool
	
	@State private var topSafeInset: CGFloat = .zero
	
	public static let defaultHeight: CGFloat = NavigationBarDimension.height
	public static let defaultOffset: CGFloat = 80

	@Environment(\.colorScheme) private var colorScheme: ColorScheme
	@Environment(\.safeFrameInsets) private var safeFrameInsets: UIEdgeInsets
	
	public init(
		   on scroll: CGPoint,
		after offset: CGFloat = Self.defaultOffset,
			  height: CGFloat = Self.defaultOffset,
		     measure: MeasureType = .single,
			   style: UIBlurEffect.Style? = nil,
		       debug: Bool = false
	) {
		self.height = height
		self.customStyle = style
		self.show = scroll.y < -offset
		self.measureType = measure
		self.debug = debug
	}
	
	private var style: UIBlurEffect.Style {
		customStyle ?? .auto(colorScheme)
	}
	
	public func body(content: Content) -> some View {
		ZStack(alignment: .top) {
			content
				.zIndex(20)
			
			if topSafeInset.isZero || measureType.is(.continuous) {
				GeometryReader { geometry in
					Color.almostClear
						.transformPreference(SafeInsetsTopKey.self) {
							if debug {
								print("=== top < \(geometry.safeAreaInsets.top)")
							}
							$0 = geometry.safeAreaInsets.top
						}
						.onPreferenceChange(SafeInsetsTopKey.self) {
							if debug {
								print("=== top > \($0)")
							}
							self.topSafeInset = $0
						}
				}
				.zIndex(10)
			}
			
			BlurredBackgroundView(style: self.style)
				.height(show ? height + safeFrameInsets.top : 0)
				.padding(.bottom, .hairline)
				.overlay(
					aligned: .bottom,
					Color(.separator)
						.height(.hairline)
				)
				.apply(when: topSafeInset.isNotZero) {
					$0.offset(y: -topSafeInset)
				}
				.animation(.spring(), value: show)
				.zIndex(40)
			
			if debug {
				debugSizes.zIndex(30)
			}
		}
	}
	
	private var debugSizes: some View {
		GeometryReader { geometry in
			Color.clear
				.overlay(LinearGradient.vertical(from: .blue, to: .orange).opacity(0.3))
				.debugFrame(blurred: false, alignment: .bottom)
				.overlay(
					aligned: .bottom,
					VStack.LabeledViews {
						self.safeFrameInsets.top.labeledView(label: "device")
						geometry.safeAreaInsets.top.labeledView(label: "screen")
						self.topSafeInset.labeledView(label: "measured", fractionDigits: 0)
						self.show.labeledView(label: "show")
					}
					.padding(.bottom, 19)
				)
				.overlay(Color.blue.height(1), alignment: .top)
				.overlay(Color.orange.height(1), alignment: .bottom)
				.height(geometry.size.height)
				.offset(y: -geometry.safeAreaInsets.top)
		}
		.height(height + safeFrameInsets.top)
	}
	
	public enum MeasureType: EasyCaseComparable {
		case single
		case continuous
	}
	
	private struct SafeInsetsTopKey: PreferenceKey {
		public static var defaultValue: CGFloat = .zero
		public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
			value = nextValue()
		}
	}
	
	/*
	private struct SafeInsetsKey: PreferenceKey {
		public static var defaultValue: EdgeInsets = .zero
		public static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
			value = nextValue()
		}
	}
	*/
}

public struct NavigationBarDimension {
	public static let height: CGFloat = 48
}

public extension UIBlurEffect.Style {
	var oppositeColor: Color {
		switch self {
			
		case .extraLight: fallthrough
		case .systemUltraThinMaterialLight: fallthrough
		case .systemThinMaterialLight: fallthrough
		case .systemMaterialLight: fallthrough
		case .systemThickMaterialLight: fallthrough
		case .systemChromeMaterialLight: fallthrough
		case .light:
			return .black
		
		case .systemUltraThinMaterialDark: fallthrough
		case .systemThinMaterialDark: fallthrough
		case .systemMaterialDark: fallthrough
		case .systemThickMaterialDark: fallthrough
		case .systemChromeMaterialDark: fallthrough
		case .dark:
			return .white
		
		case .regular: fallthrough
		case .prominent: fallthrough
		case .systemUltraThinMaterial: fallthrough
		case .systemThinMaterial: fallthrough
		case .systemMaterial: fallthrough
		case .systemThickMaterial: fallthrough
		case .systemChromeMaterial: fallthrough
		@unknown default:
			return Color(.label)
		}
	}
}

public extension View {
	/// Please apply the following modifiers before this one:
	/// ```
	/// view
	/// .transparentNavigationBarAppliedOnce()
	/// .forceNavigationBarHidden()
	/// .edgesIgnoringSafeArea(.top)
	/// .autoShowHeaderBackground(on: $scroll) // <-- last one
	/// ```
	func autoShowHeaderBackground(
		on scroll: CGPoint,
		after offset: CGFloat = ShowHeaderBackgroundViewModifier.defaultOffset,
		height: CGFloat = ShowHeaderBackgroundViewModifier.defaultHeight,
		measure: ShowHeaderBackgroundViewModifier.MeasureType = .single,
		style: UIBlurEffect.Style? = nil,
		debug: Bool = false
	) -> some View {
		modifier(
			ShowHeaderBackgroundViewModifier(
				     on: scroll,
				  after: offset,
				 height: height,
				measure: measure,
				  style: style,
				  debug: debug
			)
		)
	}
}
