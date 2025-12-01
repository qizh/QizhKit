//
//  Color+brightness+luminance.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 30.11.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension Color {
	/// Resolves a `Color` to sRGB-like components for the given environment (HDR-aware when available).
	public static func resolvedComponents(
		of color: Color,
		in environment: EnvironmentValues
	) -> ResolvedComponents {
		if #available(iOS 26.0, macOS 26.0, *) {
			// MARK: HDR-aware path
			color.resolveHDR(in: environment).resolvedComponents
		} else {
			// MARK: Fallback
			/// Pre-HDR API (iOS 17, etc.) using `Color.resolve(in:)`
			color.resolve(in: environment).resolvedComponents
			
			/*
			/// Pre-HDR API (iOS 17, etc.) using `Color.resolve(in:)`
			/// [oai_citation:2‡Jesse Squires](
			/// 	https://www.jessesquires.com/blog/2023/07/11/creating-dynamic-colors-in-swiftui
			/// )
			let resolvedColor = color.resolve(in: environment)
			let cgColor = color.resolve(in: environment).cgColor
			if let components = cgColor.components {
				return ResolvedComponents(components: components.map(\.native), alpha: cgColor.alpha)
			} else {
				return .black
			}
			*/
		}
	}
	
	
	/// Returns WCAG 2.1 relative luminance (0 = dark, 1 = light).
	public static func relativeLuminance(
		of color: Color,
		in environment: EnvironmentValues
	) -> Double {
		resolvedComponents(of: color, in: environment)
			.zeroOneClipped
			.sRGBToLinearWCAG21
			.relativeLuminance
	}
	
	/// Returns a simple perceived brightness estimate.
	public static func brightness(
		of color: Color,
		in environment: EnvironmentValues
	) -> Double {
		produceResult(
			with: resolvedComponents(of: color, in: environment)
		) { c in
			(c.red * 0.299) + (c.green * 0.587) + (c.blue * 0.114)
		}
	}
}

extension Color.ResolvedComponents {
	/// Output color space for resolved components.
	public enum Representation: Hashable, Sendable {
		/// Standard sRGB (gamma-encoded)
		case sRGB
		/// Linear-light values suitable for WCAG 2.1 math
		case WCAG21
	}
}

extension Color {
	/// A resolved color's channel values with optional linear-light flag.
	public struct ResolvedComponents: Hashable, Sendable {
		/// Red channel value (0...1)
		public let red: Double
		/// Green channel value (0...1)
		public let green: Double
		/// Blue channel value (0...1)
		public let blue: Double
		/// Alpha channel value (0...1)
		public let opacity: Double
		/// Indicates whether RGB channels are linear-light.
		public let isLinear: Bool
		
		/// Alias for `red`.
		@inlinable public var r: Double { red }
		/// Alias for `green`.
		@inlinable public var g: Double { green }
		/// Alias for `blue`.
		@inlinable public var b: Double { blue }
		/// Alias for `opacity`.
		@inlinable public var a: Double { opacity }
		
		/// Creates components from explicit channels.
		/// - Parameters:
		///   - isLinear: Set `true` if channels are linear-light.
		///   - red: Red (0...1)
		///   - green: Green (0...1)
		///   - blue: Blue (0...1)
		///   - opacity: Alpha (0...1)
		public init(
			linear isLinear: Bool,
			red: Double,
			green: Double,
			blue: Double,
			opacity: Double
		) {
			self.isLinear = isLinear
			self.red = red
			self.green = green
			self.blue = blue
			self.opacity = opacity
		}
		
		/*
		@inlinable public init(r red: Double, g green: Double, b blue: Double, a alpha: Double) {
			self.init(
				red: red,
				green: green,
				blue: blue,
				opacity: alpha
			)
		}
		*/
		
		/// Creates components from generic floating-point channels.
		public init<F>(
			linear isLinear: Bool,
			r red: F,
			g green: F,
			b blue: F,
			a alpha: F
		) where F: BinaryFloatingPoint {
			self.init(
				linear: isLinear,
				red: Double(red),
				green: Double(green),
				blue: Double(blue),
				opacity: Double(alpha)
			)
		}
		
		/// Creates grayscale components with optional alpha.
		@inlinable public init(
			linear isLinear: Bool,
			white: Double,
			opacity: Double = 1.0
		) {
			self.init(
				linear: isLinear,
				red: white,
				green: white,
				blue: white,
				opacity: opacity
			)
		}
		
		/// Creates components from an array.
		/// Interprets 2 values as grayscale+alpha, 3 as RGB, 4+ takes the first three as RGB and uses `alpha`.
		public init(
			linear isLinear: Bool,
			components: [Double],
			alpha: Double = 1.0
		) {
			switch components.count {
			case 2:
				/// grayscale + alpha
				self.init(
					linear: isLinear,
					white: components[0],
					opacity: components[1]
				)
			case 3:
				/// RGB, no explicit alpha
				self.init(
					linear: isLinear,
					r: components[0],
					g: components[1],
					b: components[2],
					a: alpha
				)
			default:
				/// 4 or more – take first three as RGB
				self.init(
					linear: isLinear,
					r: components[0],
					g: components[1],
					b: components[2],
					a: alpha
				)
			}
		}
		
		/// Convenience initializer from CGFloat components.
		@inlinable public init(
			linear isLinear: Bool,
			components: [CGFloat],
			alpha: Double = 1.0
		) {
			self.init(
				linear: isLinear,
				components: components.map(\.native),
				alpha: alpha
			)
		}
		
		/// Initializes from a SwiftUI `Color.Resolved`.
		public init(
			linear isLinear: Bool,
			_ resolved: Color.Resolved
		) {
			if isLinear {
				self.init(
					linear: true,
					r: resolved.linearRed,
					g: resolved.linearGreen,
					b: resolved.linearBlue,
					a: resolved.opacity
				)
			} else {
				self.init(
					linear: false,
					r: resolved.red,
					g: resolved.green,
					b: resolved.blue,
					a: resolved.opacity
				)
			}
		}
		
		/// Initializes from a SwiftUI `Color.ResolvedHDR`.
		@available(iOS 26.0, *)
		public init(
			linear isLinear: Bool,
			_ resolvedHDR: Color.ResolvedHDR
		) {
			if isLinear {
				self.init(
					linear: true,
					r: resolvedHDR.linearRed.double,
					g: resolvedHDR.linearGreen.double,
					b: resolvedHDR.linearBlue.double,
					a: resolvedHDR.opacity.double
				)
			} else {
				self.init(
					linear: false,
					r: resolvedHDR.red.double,
					g: resolvedHDR.green.double,
					b: resolvedHDR.blue.double,
					a: resolvedHDR.opacity.double
				)
			}
		}
		
		/// Convenience white in sRGB.
		public static let white: Self = .init(linear: false, white: 1)
		/// Convenience black in sRGB.
		public static let black: Self = .init(linear: false, white: 0)
	}
}

extension Color.ResolvedComponents {
	public var sRGBToLinearWCAG21: Color.ResolvedComponents {
		if isLinear {
			self
		} else {
			Color.ResolvedComponents(
				linear: true,
				r: .sRGBToLinearWCAG21(red),
				g: .sRGBToLinearWCAG21(green),
				b: .sRGBToLinearWCAG21(blue),
				a: opacity
			)
		}
	}
	
	/// Using `WCAG 2.1` relative luminance formula
	public var relativeLuminance: Double {
		if isLinear {
			  0.2126 * r
			+ 0.7152 * g
			+ 0.0722 * b
		} else {
			sRGBToLinearWCAG21.relativeLuminance
		}
	}
	
	/// Simple “perceived brightness” convenience
	public var brightness: Double {
		if isLinear {
			  0.299 * r
			+ 0.587 * g
			+ 0.114 * b
		} else {
			sRGBToLinearWCAG21.brightness
		}
	}
	
	/// Returns a copy with all channels clamped to 0...1.
	public var zeroOneClipped: Color.ResolvedComponents {
		Color.ResolvedComponents(
			linear: isLinear,
			r: r.zeroOneClipped,
			g: g.zeroOneClipped,
			b: b.zeroOneClipped,
			a: a.zeroOneClipped
		)
	}
}

extension Color.Resolved {
	/// sRGB components from this resolved color.
	public var resolvedComponents: Color.ResolvedComponents {
		Color.ResolvedComponents(
			linear: false,
			r: red.double,
			g: green.double,
			b: blue.double,
			a: opacity.double
		)
	}
	
	/// Linear-light components from this resolved color.
	public var linearResolvedComponents: Color.ResolvedComponents {
		Color.ResolvedComponents(
			linear: true,
			r: linearRed.double,
			g: linearGreen.double,
			b: linearBlue.double,
			a: opacity.double
		)
	}
}

@available(iOS 26.0, *)
extension Color.ResolvedHDR {
	/// sRGB components from this HDR-resolved color.
	public var resolvedComponents: Color.ResolvedComponents {
		Color.ResolvedComponents(
			linear: false,
			r: red.double,
			g: green.double,
			b: blue.double,
			a: opacity.double
		)
	}
	
	/// Linear-light components from this HDR-resolved color.
	public var linearResolvedComponents: Color.ResolvedComponents {
		Color.ResolvedComponents(
			linear: true,
			r: linearRed.double,
			g: linearGreen.double,
			b: linearBlue.double,
			a: opacity.double
		)
	}
}

extension Double {
	/// Converts an `sRGB` color component into its linearized form
	/// for luminance calculations.
	///
	/// - Invariant:
	///   This applies the `WCAG 2.1` `sRGB` companding function:
	///   - If the input (clipped to `0...1`) is `≤ 0.03928`, it divides by `12.92`.
	///   - Otherwise, it applies the inverse gamma:
	///     ```swift
	///     ((v + 0.055) / 1.055) ^ 2.4
	///     ```
	/// - Parameters:
	///   - value: The `sRGB` component value, expected in the `0...1` range.
	///     - Values outside this range are clipped before conversion.
	/// - Returns:
	///   A linear-light component value in the `0...1` range
	///   suitable for computing relative luminance.
	/// - Note:
	///   This conversion is required to compute `WCAG` relative luminance
	///   from `sRGB` values, ensuring that perceptual gamma is removed
	///   prior to applying the luminance weights.
	/// - SeeAlso:
	///   - [WCAG 2.1](https://www.w3.org/TR/WCAG21/)
	///   - [Relative Luminance definition](https://en.wikipedia.org/wiki/Relative_luminance)
	public static func sRGBToLinearWCAG21(@ZeroOneClamped _ value: Double) -> Self {
		if value <= 0.03928 {
			value / 12.92
		} else {
			pow((value + 0.055) / 1.055, 2.4)
		}
	}
	
	/// Converts an `sRGB` color component to its linear-light representation
	/// according to `WCAG 2.1`.
	///
	/// This function removes the `sRGB` gamma companding so the component can be used in
	/// `linear` operations such as computing `relative luminance` or performing
	/// physically-based blending.
	///
	/// - Invariant:
	///   This applies the `WCAG 2.1` `sRGB` companding function:
	///   - If the input (clipped to `0...1`) is `≤ 0.03928`, it divides by `12.92`.
	///   - Otherwise, it applies the inverse gamma:
	///     ```swift
	///     ((v + 0.055) / 1.055) ^ 2.4
	///     ```
	/// - Precondition: Expected input range is `0...1`.
	/// - Postcondition:
	///   - Values outside this range are going to be clamped to `0...1` range before conversion.
	///   - The returned value is also in `0...1` for inputs within range.
	/// - Note:
	///   ### Typical use cases:
	///   - Computing `WCAG` relative luminance for contrast calculations
	///   - Converting UI colors to linear space for accurate compositing
	///   - Preparing color components for `HDR`/scene-linear workflows
	/// - SeeAlso:
	///   - [WCAG 2.1](https://www.w3.org/TR/WCAG21/)
	///   - [Relative luminance](https://en.wikipedia.org/wiki/Relative_luminance)
	/// - Parameter value: An `sRGB` component in `0...1` to be linearized.
	/// - Returns: The linear-light component suitable for luminance and linear color math.
	@inlinable public var sRGBToLinearLightWCAG21: Double {
		.sRGBToLinearWCAG21(self)
	}
}

