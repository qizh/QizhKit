//
//  HeaderBackground.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 24.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import Combine
import DeviceKit

public struct ShowHeaderBackgroundViewModifier: ViewModifier {
	private let height: CGFloat
	private let customStyle: UIBlurEffect.Style?
	@State private var measurementsCount: Int = .zero
	@State private var measureType: MeasureType

	private let show: Bool
	private let debug: Bool
	
	@State private var topSafeInset: CGFloat = .zero
	
	public static let defaultHeight: CGFloat = NavigationBarDimension.height
	public static let defaultOffset: CGFloat = 80

	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.safeFrameInsets) private var safeFrameInsets
	
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
		self._measureType = .init(initialValue: measure)
		self.debug = debug
	}
	
	private var style: UIBlurEffect.Style {
		customStyle ?? .auto(colorScheme)
	}
	
	public func body(content: Content) -> some View {
		ZStack(alignment: .top) {
			content
				.zIndex(20)
			
			GeometryReader { geometry -> Color in
				executeUpdate($topSafeInset, with: geometry.safeAreaInsets.top)
				return Color.clear
			}
			.zIndex(10)
			
			/*
			if topSafeInset.isZero || measureType > .single {
				GeometryReader { geometry in
					Color.almostClear
						.transformPreference(SafeInsetsTopKey.self) {
							if debug {
								print("=== top < \(geometry.safeAreaInsets.top)")
							}
							let topInset = geometry.safeAreaInsets.top
							$0 = topInset
							
							if measureType == .few, topSafeInset == topInset {
								execute {
									measurementsCount += .one
									if measurementsCount >= 3 {
										measureType = .single
									}
								}
							}
							
							if #available(iOS 14, *), topSafeInset != topInset {
								execute {
									topSafeInset = topInset
								}
							}
						}
						.onPreferenceChange(SafeInsetsTopKey.self) { top in
							if debug {
								print("=== top > \(top), measure: \(measureType)")
							}
							topSafeInset = top
						}
				}
				.zIndex(10)
			}
			*/
			
			BlurredBackgroundView(style: self.style)
				.height(show ? height + safeFrameInsets.top : 0)
				.padding(.bottom, .hairline)
				.overlay(.bottom, Color(.separator).height(.hairline))
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
				.overlay(.bottom) {
					VStack.LabeledViews {
						self.safeFrameInsets.top.labeledView(label: "device")
						geometry.safeAreaInsets.top.labeledView(label: "screen")
						self.topSafeInset.labeledView(label: "measured", fractionDigits: 0)
						self.show.labeledView(label: "show")
					}
					.padding(.bottom, 19)
				}
				.overlay(Color.blue.height(1), alignment: .top)
				.overlay(Color.orange.height(1), alignment: .bottom)
				.height(geometry.size.height)
				.offset(y: -geometry.safeAreaInsets.top)
		}
		.height(height + safeFrameInsets.top)
	}
	
	public enum MeasureType: Comparable, EasyCaseComparable {
		case single
		case few
		case continuous
	}
	
	/*
	private struct SafeInsetsTopKey: PreferenceKey {
		public static var defaultValue: CGFloat = .zero
		public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
			value = nextValue()
		}
	}
	*/
	
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
	public static var height: CGFloat {
		if Device.current.isPad {
			50
		} else if Device.current.isPhone {
			if Device.current.hasDynamicIsland {
				39 /// Maybe `40`?
			} else {
				44
			}
		} else {
			44
		}
	}
	
	public static var safeFrameTop: CGFloat {
		Device.current.hasDynamicIsland ? 59 : 44
	}
	
	public static var safeFrameBottom: CGFloat {
		Device.current.hasRoundedDisplayCorners ? 34 : 0
	}
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
	///   .transparentNavigationBarAppliedOnce()
	///   // .forceNavigationBarHidden()
	///   .edgesIgnoringSafeArea(.top)
	///   .autoShowHeaderBackground(on: $scroll) // <-- last one
	/// ```
	/// - Parameters:
	///   - scroll: `UIScrollView` offset `CGPoint`
	///   - offset: Scroll offset when header appears. Default value: `80`
	///   - height: Header height. Default value: `44`
	///   - measure: Type of safe area measurement. Default value: `.single`
	///   - style: Blur effect style.
	///   `.auto(colorScheme)` value is used when no value provided
	///   - debug: Show visual debug
	/// - Returns: `ZStack` with content and header
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
