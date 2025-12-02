//
//  Color+brightness+luminance.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 30.11.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension Color {
	/// Resolves a `SwiftUI` `Color` into concrete channel values for a specific
	/// `EnvironmentValues`, returning `sRGB`-like components with an indicator for
	/// linear-light interpretation.
	///
	/// This utility bridges `SwiftUI`’s abstract `Color` with concrete numeric components
	/// you can use for calculations (e.g., luminance, contrast, or custom blending).
	/// It automatically chooses the best available resolution API for the current platform
	/// and SDK:
	/// - On platforms where HDR-aware resolution is available (iOS 26, macOS 26 and later),
	///   it uses `Color.resolveHDR(in:)` to obtain high-fidelity components.
	/// - On earlier platforms, it falls back to `Color.resolve(in:)`.
	///
	/// The returned `ResolvedComponents` contains:
	/// - `red`, `green`, `blue`, `opacity`: normalized channel values (`0...1`)
	/// - `isLinear`: whether the RGB channels are linear-light (`true`)
	///   or gamma-encoded `sRGB` (`false`)
	/// - Note:
	///   - The exact numeric values can vary by environment
	///     (e.g., color scheme, accessibility settings).
	///   - Use `ResolvedComponents.relativeLuminance` for `WCAG 2.1` luminance and
	///     `ResolvedComponents.brightness` for a quick perceived brightness estimate.
	///   - For linear color math, prefer the linear-light interpretation
	///     (`isLinear == true`).
	/// - Parameters:
	///   - color: The `SwiftUI` `Color` to resolve.
	///   - environment: The `EnvironmentValues` context in which to resolve the color.
	/// - Returns:
	///   A `ResolvedComponents` value containing `sRGB`-like channels and a linear-light
	///   flag, suitable for luminance/contrast calculations or further color processing.
	/// - Attention:
	///   HDR-aware resolution is used automatically when available (iOS 26, macOS 26 and
	///   later), otherwise the function falls back to the pre-HDR resolve API.
	/// - SeeAlso:
	///   - ``ResolvedComponents``
	///   - ``resolve(in:)``
	///   - ``resolveHDR(in:)``
	///   - `Color.Resolved.resolvedComponents`
	///   - `Color.Resolved.linearResolvedComponents`
	public static func resolvedComponents(
		of color: Color,
		in environment: EnvironmentValues
	) -> ResolvedComponents {
		#if RESOLVED_HDR_AVAILABLE
		if #available(iOS 26.0, macOS 26.0, *) {
			// MARK: HDR-aware path
			color.resolveHDR(in: environment).resolvedComponents
		} else {
			// MARK: Fallback: pre-HDR API (iOS 17, etc.) using `Color.resolve(in:)`
			color.resolve(in: environment).resolvedComponents
		}
		#else
		// MARK: Fallback-only build
		/// When `Color.resolveHDR` / `Color.ResolvedHDR` not available in this SDK
		color.resolve(in: environment).resolvedComponents
		#endif
	}
	
	/// Resolves the receiver (`Color`) into concrete channel values for a given
	/// `EnvironmentValues` context, returning `sRGB`-like components along with a flag
	/// indicating whether the RGB channels are linear-light.
	///
	/// This is a convenience wrapper around `Color.resolvedComponents(of:in:)` that
	/// bridges `SwiftUI`’s abstract `Color` to numeric components suitable for color math
	/// (e.g., luminance, contrast, or custom blending).
	/// ## Behavior
	/// - On platforms where HDR-aware resolution is available
	///   (`iOS 26`, `macOS 26` and later), it uses `Color.resolveHDR(in:)`
	///   to obtain high-fidelity components.
	/// - On earlier platforms, it falls back to `Color.resolve(in:)`.
	/// - Note:
	///   - The exact numeric values can vary by environment
	///     (e.g., color scheme, accessibility).
	///   - Use `ResolvedComponents.relativeLuminance` for `WCAG 2.1` luminance and
	///     `ResolvedComponents.brightness` for a quick perceived brightness estimate.
	///   - For linear color math, prefer the linear-light interpretation
	///     (`isLinear == true`).
	/// - Parameter environment: The `EnvironmentValues` context
	///   in which to resolve the color.
	/// - Returns: A `ResolvedComponents` value containing `sRGB`-like channels
	///   and a linear-light flag.
	///   ## The returned `Color.ResolvedComponents` contains:
	///   - `red`, `green`, `blue`, `opacity`: normalized channel values (`0...1`)
	///   - `isLinear`: whether the RGB channels represent linear-light (`true`) or
	///     gamma-encoded `sRGB` (`false`)
	/// - SeeAlso:
	///   - ``Color/resolvedComponents(of:in:)``
	///   - ``Color/ResolvedComponents``
	///   - ``Color/Resolved/resolvedComponents``
	///   - ``Color/Resolved/linearResolvedComponents``
	@inlinable public func resolvedComponents(
		in environment: EnvironmentValues
	) -> ResolvedComponents {
		Color.resolvedComponents(of: self, in: environment)
	}
		
	/// Returns `WCAG 2.1` relative luminance (`0` = dark, `1` = light).
	@inlinable public static func relativeLuminance(
		of color: Color,
		in environment: EnvironmentValues
	) -> Double {
		resolvedComponents(of: color, in: environment).relativeLuminance
	}
	
	/// Returns `WCAG 2.1` relative luminance (`0` = dark, `1` = light).
	@inlinable public func relativeLuminance(
		resolvedIn environment: EnvironmentValues
	) -> Double {
		Self.relativeLuminance(of: self, in: environment)
	}
	
	/// Returns a simple perceived brightness estimate.
	@inlinable public static func brightness(
		of color: Color,
		in environment: EnvironmentValues
	) -> Double {
		resolvedComponents(of: color, in: environment).brightness
	}
	
	/// Returns a simple perceived brightness estimate.
	@inlinable public func brightness(
		resolvedIn environment: EnvironmentValues
	) -> Double {
		Self.brightness(of: self, in: environment)
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
		/// Red channel value (`0...1`)
		public let red: Double
		/// Green channel value (`0...1`)
		public let green: Double
		/// Blue channel value (`0...1`)
		public let blue: Double
		/// Alpha channel value (`0...1`)
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
		
		/// Creates a resolved color component set from explicit channel values.
		///
		/// Use this initializer when you already have individual channel values and want to
		/// create a `Color.ResolvedComponents` value in either sRGB (gamma-encoded) or
		/// linear-light space.
		/// - Parameters:
		///   - isLinear: A Boolean indicating whether the provided `red`, `green`, and
		///     `blue` values are in linear-light space (`true`) or are gamma-encoded `sRGB`
		///     values (`false`).
		///   - red: The red channel value in the range `0...1`.
		///   - green: The green channel value in the range `0...1`.
		///   - blue: The blue channel value in the range `0...1`.
		///   - opacity: The alpha (opacity) channel value in the range `0...1`.
		/// - Important:
		///   Values are expected to be within `0...1`.
		///   No automatic clamping is performed.
		/// - SeeAlso:
		///   - ``sRGBToLinearWCAG21`` for converting `sRGB` components to linear-light values
		///   - ``relativeLuminance`` for `WCAG 2.1` luminance computed from linear-light
		///     components
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
		
		/// Creates color components from explicit RGB and alpha channel values with a
		/// linear-light flag.
		///
		/// Use this initializer when you have individual channel values and need to specify
		/// whether they are in linear-light space or gamma-encoded `sRGB`.
		/// - Parameters:
		///   - isLinear: A Boolean indicating the interpretation of the RGB channels:
		///     - `true` if `red`, `green`, and `blue` are linear-light values.
		///     - `false` if they are gamma-encoded sRGB values.
		///   - red: The red channel value in the range `0...1`.
		///   - green: The green channel value in the range `0...1`.
		///   - blue: The blue channel value in the range `0...1`.
		///   - alpha: The opacity (alpha) channel value in the range `0...1`.
		/// - Important:
		///   Values are expected to be within `0...1`.
		///   No automatic clamping is performed.
		/// - SeeAlso:
		///   - ``sRGBToLinearWCAG21`` for converting `sRGB` components to linear-light
		///   - ``relativeLuminance`` for `WCAG 2.1` luminance computed from linear-light
		///     components
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
		
		/// Creates a grayscale `Color.ResolvedComponents` value with an optional alpha,
		/// specifying whether the provided channels are linear-light or gamma-encoded sRGB.
		///
		/// Use this initializer when you have a single grayscale intensity and want to
		/// populate all RGB channels equally, optionally providing an opacity value.
		/// The `isLinear` flag controls whether the grayscale value is interpreted as
		/// linear-light (`true`) or as gamma-encoded sRGB (`false`).
		/// - Parameters:
		///   - isLinear: Pass `true` if `white` is a linear-light value;
		///     pass `false` if it is a gamma-encoded sRGB value.
		///   - white: The grayscale intensity applied to the red, green, and blue channels,
		///     expected in the `0...1` range.
		///   - opacity: The alpha (opacity) channel value, expected in the `0...1` range.
		///     Defaults to `1.0`.
		/// - Important:
		///   Values are expected to be within `0...1`. No automatic clamping is performed.
		/// - SeeAlso:
		///   - ``init(linear:r:g:b:a:)`` for explicit RGB(A) construction
		///   - ``sRGBToLinearWCAG21`` for converting sRGB components to linear-light
		///   - ``relativeLuminance`` for WCAG 2.1 luminance computed from linear-light
		///     components
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
		
		/// Creates a `Color.ResolvedComponents` value from an array of channel values,
		/// optionally specifying whether the values are in linear-light space
		/// and an explicit alpha.
		///
		/// This initializer provides a flexible way to construct color components from a
		/// variable-length array.
		/// - It supports:
		///   - `grayscale` (with embedded alpha)
		///   - `RGB` (without alpha)
		///   - `RGBA`-like inputs (taking the first three as RGB)
		/// - For `RGB`-only arrays, the `alpha` parameter is applied.
		/// - For arrays with two elements, the second is treated as `opacity`.
		/// - Parameters:
		///   - isLinear: A Boolean that indicates whether the provided channel values either
		///     - are in linear-light space (`true`)
		///     - are gamma-encoded `sRGB` values (`false`)
		///   - components: The source channel values interpreted as follows:
		///       - If the array has `2` elements, they are treated as `[white, alpha]`
		///         (grayscale plus opacity).
		///       - If the array has `3` elements, they are treated as `[red, green, blue]`
		///         with the `alpha` parameter applied.
		///       - If the array has `4` or more elements, the first three are treated as
		///         `[red, green, blue]` with the `alpha` parameter applied.
		///   - alpha: The opacity value to use when `components` does not include an
		///     explicit alpha (defaults to `1.0`).
		/// - Precondition:
		///   Values are expected to be in the `0...1` range;
		///   no automatic clamping is performed by this initializer.
		/// - SeeAlso:
		///   - ``init(linear:white:opacity:)`` for explicit grayscale construction
		///   - ``init(linear:r:g:b:a:)`` for explicit RGB(A) construction
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
		
		/// Creates a `Color.ResolvedComponents` value from an array of channel values,
		/// specifying whether the values are linear-light and optionally providing an
		/// explicit alpha.
		///
		/// Use this initializer when you have a variable-length collection of components
		/// and need to form RGB(A) or grayscale color data with a chosen interpretation
		/// (linear-light vs sRGB).
		///
		/// Behavior based on the number of elements in components:
		/// - If `components.count == 2`:
		///   - Treated as `[white, alpha]` (grayscale + opacity).
		/// - If `components.count == 3`:
		///   - Treated as `[red, green, blue]` with the provided alpha parameter applied.
		/// - If `components.count >= 4`:
		///   - The first three values are taken as `[red, green, blue]` with the provided
		///     alpha parameter applied.
		/// - Parameters:
		///   - isLinear:
		///     - Pass `true` if the provided channels are linear-light values.
		///     - Pass `false` if they are gamma-encoded `sRGB` values.
		///   - components: The source channel values interpreted as described above.
		///     - Values are expected to be in the `0...1` range.
		///     - No automatic clamping is performed.
		///   - alpha: The opacity to use when components does not include an explicit alpha
		///     (defaults to `1.0`).
		/// - Precondition:
		///   Channel values are expected to be within `0...1`.
		///   This initializer does not clamp.
		/// - Important:
		///   Ensure you pass isLinear correctly for your workflow:
		///   - `true` for linear-light math (e.g., WCAG luminance, physically-based blending)
		///   - `false` for standard gamma-encoded sRGB values.
		/// - SeeAlso:
		///   - ``init(linear:white:opacity:)`` for explicit grayscale construction
		///   - ``init(linear:r:g:b:a:)`` for explicit RGB(A) construction
		///   - ``sRGBToLinearWCAG21`` for converting sRGB components to linear-light
		///   - ``relativeLuminance`` for `WCAG 2.1` luminance computed from linear-light
		///     components
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
		
		/// Initializes a `Color.ResolvedComponents` value from a SwiftUI `Color.Resolved`,
		/// optionally interpreting the RGB channels as linear-light values.
		///
		/// Use this initializer when you have already resolved a SwiftUI Color into the
		/// current `EnvironmentValues` (via `Color.resolve(in:)`) and you want its channel
		/// values packaged as `ResolvedComponents`. You can choose whether to store the
		/// channels as gamma-encoded sRGB or as linear-light values suitable for WCAG/linear
		/// color math.
		/// - Parameters:
		///   - isLinear: Pass `true` to interpret and store the resolved RGB channels as
		///     linear-light values (`linearRed`, `linearGreen`, `linearBlue`); pass `false`
		///     to use the standard gamma-encoded sRGB channels (`red`, `green`, `blue`).
		///   - resolved: The SwiftUI `Color.Resolved` instance produced by resolving
		///     a `Color` in a specific EnvironmentValues context.
		/// - Important: Channel values are expected to be in the `0...1` range. This
		///   initializer does not perform automatic clamping.
		/// - SeeAlso:
		///   - ``Color/ResolvedComponents/sRGBToLinearWCAG21``
		///   - ``Color/ResolvedComponents/relativeLuminance``
		///   - ``Color/ResolvedComponents/brightness``
		///   - ``Color/Resolved/resolvedComponents``
		///   - ``Color/Resolved/linearResolvedComponents``
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

		#if RESOLVED_HDR_AVAILABLE
		/// Initializes a `Color.ResolvedComponents` from a SwiftUI `Color.Resolved`,
		/// optionally interpreting the resolved RGB channels as linear-light values.
		///
		/// Use this initializer when you already have a `Color.Resolved` (obtained via
		/// `Color.resolve(in:)`) and you need the channel values packaged as
		/// `ResolvedComponents`, either in gamma-encoded sRGB form or in linear-light
		/// form suitable for WCAG/linear math.
		///
		/// - Parameters:
		///   - isLinear: Pass `true` to interpret and store the resolved RGB channels
		///     as linear-light values (`linearRed`, `linearGreen`, `linearBlue`);
		///     pass `false` to use the standard gamma-encoded sRGB channels
		///     (`red`, `green`, `blue`).
		///   - resolved: The SwiftUI `Color.Resolved` instance produced by resolving
		///     a `Color` in a specific `EnvironmentValues` context.
		/// - Important: Channel values are expected to be in the `0...1` range. This
		///   initializer does not perform automatic clamping.
		/// - SeeAlso:
		///   - ``Color/ResolvedComponents/sRGBToLinearWCAG21``
		///   - ``Color/ResolvedComponents/relativeLuminance``
		///   - ``Color/ResolvedComponents/brightness``
		///   - ``Color/Resolved/resolvedComponents``
		///   - ``Color/Resolved/linearResolvedComponents``
		@available(iOS 26.0, macOS 26.0, *)
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
		#endif
		
		/// Convenience white in sRGB.
		public static let white: Self = .init(linear: false, white: 1)
		/// Convenience black in sRGB.
		public static let black: Self = .init(linear: false, white: 0)
	}
}

extension Color.ResolvedComponents {
	/// Converts a gamma-encoded `sRGB` component into its linear-light equivalent
	/// using the `WCAG 2.1` transfer function.
	///
	/// This helper is intended for preparing color channel values
	/// (`red`, `green`, or `blue`) for linear color math such as computing
	/// relative luminance or performing physically accurate blending.
	/// It clamps the input to the `0...1` range before conversion and returns a value
	/// in the same range.
	/// - Invariant:
	///   Algorithm (`WCAG 2.1` `sRGB` companding inverse)
	///   ```
	///   Let `v` be the input component after clamping to `0...1`.
	///   If `v ≤ 0.03928`:
	///     return `v / 12.92`
	///   Else:
	///     return `((v + 0.055) / 1.055) ^ 2.4`
	///   ```
	/// - Note:
	///   - Use on individual sRGB components prior to computing WCAG relative luminance:
	///     ```
	///     Y = 0.2126 * R_lin + 0.7152 * G_lin + 0.0722 * B_lin
	///     ```
	///   - Apply to each of `R`, `G`, `B` separately when converting an `sRGB` color
	///     to linear space.
	/// - Returns:
	///   The linear-light component suitable for WCAG luminance and other linear operations.
	/// - SeeAlso:
	///   - [WCAG 2.1](https://www.w3.org/TR/WCAG21/)
	///   - [Relative luminance](https://en.wikipedia.org/wiki/Relative_luminance)
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
	
	/// The `WCAG 2.1` relative luminance of the color’s RGB channels, normalized to `0...1`.
	///
	/// Relative luminance is a linear-light measure of perceived brightness used by WCAG for
	/// contrast calculations. It is computed from linear RGB components using the standard
	/// coefficients:
	/// ```
	/// Y = 0.2126 * R + 0.7152 * G + 0.0722 * B
	/// ```
	/// - Invariant:
	///   - If the receiver’s channels are already linear-light (`isLinear == true`),
	///     the value is computed directly using the formula above.
	///   - If the channels are gamma-encoded sRGB (`isLinear == false`),
	///     they are first converted to linear-light using the `WCAG 2.1` `sRGB` inverse
	///     transfer function, and then luminance is computed.
	/// - Note:
	///   - Inputs are effectively treated in the `0...1` range
	///     (values are clipped during linearization).
	///   - The resulting luminance is in `0...1`, where `0` is black and `1` is white.
	///   - This value is suitable for contrast ratio calculations and other
	///     accessibility-related measurements.
	/// - SeeAlso:
	///   - `WCAG 2.1`: [Relative Luminance](https://www.w3.org/TR/WCAG21/)
	///   - sRGB to linear conversion used by WCAG
	///   - `Color.ResolvedComponents.sRGBToLinearWCAG21`
	public var relativeLuminance: Double {
		if isLinear {
			  0.2126 * r
			+ 0.7152 * g
			+ 0.0722 * b
		} else {
			sRGBToLinearWCAG21.relativeLuminance
		}
	}
	
	/// A simple perceived brightness metric derived from the color’s RGB channels.
	///
	/// This property returns a single scalar in the range 0...1 that approximates
	/// how bright the color appears to the human eye. It uses the common luma
	/// weighting coefficients to combine the red, green, and blue channels:
	/// ```
	/// brightness ≈ 0.299 * R + 0.587 * G + 0.114 * B
	/// ```
	/// Behavior:
	/// - If the receiver’s channels are already linear-light (`isLinear == true`),
	///   the value is computed directly using the weights above.
	/// - If the channels are gamma-encoded sRGB (`isLinear == false`),
	///   they are first converted to linear-light using the WCAG 2.1 sRGB inverse
	///   transfer function, and then the brightness is computed.
	///
	/// - Note:
	///   - The result is a heuristic measure and not a standards-based luminance.
	///     For accessibility/contrast calculations, prefer `relativeLuminance`.
	///   - Inputs are effectively treated as normalized 0...1 values.
	///   - Unlike `relativeLuminance`, which uses WCAG coefficients
	///     `(0.2126, 0.7152, 0.0722)`, this uses traditional luma-like weights
	///     `(0.299, 0.587, 0.114)` for a quick estimate.
	/// - SeeAlso:
	///   - ``relativeLuminance`` for `WCAG 2.1`-compliant luminance
	///     suitable for contrast ratios.
	///   - ``sRGBToLinearWCAG21`` for the linearization used when `isLinear == false`.
	public var brightness: Double {
		if isLinear {
			  0.299 * r
			+ 0.587 * g
			+ 0.114 * b
		} else {
			sRGBToLinearWCAG21.brightness
		}
	}
	
	/// Returns a value clamped to the `0...1` range.
	///
	/// Use this to ensure component values (such as color channels or opacity)
	/// stay within the valid normalized bounds before further calculations.
	/// - Returns:
	///   - `0` if the value is less than `0`
	///   - `1` if the value is greater than `1`
	///   - otherwise the value itself.
	/// - SeeAlso: ``Double/sRGBToLinearLightWCAG21``
	/// - Note: This is a convenience used throughout color math to avoid out-of-range
	///   artifacts when computing luminance, brightness, or performing linear conversions.
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

#if RESOLVED_HDR_AVAILABLE
@available(iOS 26.0, macOS 26.0, *)
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
#endif

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
