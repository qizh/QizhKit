//
//  ColorBrightnessLuminanceTests.swift
//  QizhKit
//
//  Tests for Color+brightness+luminance.swift
//

#if swift(>=6.2) && canImport(Testing)

import Testing
import QizhKit
import SwiftUI
import CoreGraphics

@Suite("Color + Brightness + Luminance Tests")
struct ColorBrightnessLuminanceTests {
	
	// MARK: - Shared helpers
	
	private static let epsilon: Double = 1e-6
	
	// MARK: - Double sRGB / Linear helpers
	
	@Suite("Double.sRGBToLinearWCAG21 & sRGBToLinearLightWCAG21")
	struct DoubleLinearizationTests {
		@Test("Zero maps to zero")
		func testZeroMapsToZero() {
			let v = Double.sRGBToLinearWCAG21(0.0)
			#expect(v == 0.0)
			
			let prop: Double = 0.0
			#expect(prop.sRGBToLinearLightWCAG21 == 0.0)
		}
		
		@Test("One maps to one approximately")
		func testOneMapsToOneApproximately() {
			let v = Double.sRGBToLinearWCAG21(1.0)
			#expect(abs(v - 1.0) < ColorBrightnessLuminanceTests.epsilon)
			
			let prop: Double = 1.0
			#expect(abs(prop.sRGBToLinearLightWCAG21 - 1.0) < ColorBrightnessLuminanceTests.epsilon)
		}
		
		@Test("Clamping values below zero")
		func testClampBelowZero() {
			/// Values below 0 are clamped to 0 before conversion.
			let below = Double.sRGBToLinearWCAG21(-0.5)
			let zero = Double.sRGBToLinearWCAG21(0.0)
			#expect(below == zero)
		}
		
		@Test("Clamping values above one")
		func testClampAboveOne() {
			/// Values above 1 are clamped to 1 before conversion.
			let above = Double.sRGBToLinearWCAG21(1.5)
			let one = Double.sRGBToLinearWCAG21(1.0)
			#expect(abs(above - one) < ColorBrightnessLuminanceTests.epsilon)
		}
		
		@Test("Thrreshold check")
		func testThresholdBehavior() {
			/// 0.03928 is the WCAG threshold; just sanity-check continuity.
			let threshold: Double = 0.03928
			let slightlyBelow = threshold - 0.0001
			let slightlyAbove = threshold + 0.0001
			
			let belowLinear = Double.sRGBToLinearWCAG21(slightlyBelow)
			let aboveLinear = Double.sRGBToLinearWCAG21(slightlyAbove)
			
			#expect(belowLinear > 0.0)
			#expect(aboveLinear > belowLinear)
		}
		
		@Test("Static & property produce matching values")
		func testStaticAndPropertyMatch() {
			let value: Double = 0.5
			let staticResult = Double.sRGBToLinearWCAG21(value)
			let propertyResult = value.sRGBToLinearLightWCAG21
			#expect(abs(staticResult - propertyResult) < ColorBrightnessLuminanceTests.epsilon)
		}
	}
	
	// MARK: - ResolvedComponents initializers
	
	@Suite("Color.ResolvedComponents Initializers")
	struct ResolvedComponentsInitTests {
		@Test("Explicit channels initializer")
		func testExplicitChannelsInitializer() {
			let c = Color.ResolvedComponents(
				linear: false,
				red: 0.1,
				green: 0.2,
				blue: 0.3,
				opacity: 0.4
			)
			#expect(c.isLinear == false)
			#expect(c.red == 0.1)
			#expect(c.green == 0.2)
			#expect(c.blue == 0.3)
			#expect(c.opacity == 0.4)
			#expect(c.r == 0.1)
			#expect(c.g == 0.2)
			#expect(c.b == 0.3)
			#expect(c.a == 0.4)
		}
		
		@Test("Generic floating-point initializer")
		func testGenericFloatingPointInitializer() {
			let c = Color.ResolvedComponents(
				linear: true,
				r: CGFloat(0.25),
				g: CGFloat(0.5),
				b: CGFloat(0.75),
				a: CGFloat(1.0)
			)
			#expect(c.isLinear == true)
			#expect(c.red == 0.25)
			#expect(c.green == 0.5)
			#expect(c.blue == 0.75)
			#expect(c.opacity == 1.0)
		}
		
		@Test("Grayscale initializer")
		func testGrayscaleInitializer() {
			let c = Color.ResolvedComponents(
				linear: false,
				white: 0.3,
				opacity: 0.8
			)
			#expect(c.isLinear == false)
			#expect(c.red == 0.3)
			#expect(c.green == 0.3)
			#expect(c.blue == 0.3)
			#expect(c.opacity == 0.8)
		}
		
		@Test("Components initialized with an array of 2 values should be interpreted as grayscale and alpha")
		func testComponentsArrayTwoValuesGrayscalePlusAlpha() {
			let c = Color.ResolvedComponents(
				linear: false,
				components: [0.5, 0.25]
			)
			#expect(c.red == 0.5)
			#expect(c.green == 0.5)
			#expect(c.blue == 0.5)
			#expect(c.opacity == 0.25)
		}
		
		@Test("Components initialized with an array of 3 elements and an alpha")
		func testComponentsArrayThreeValuesRGBAlphaParameter() {
			let c = Color.ResolvedComponents(
				linear: true,
				components: [0.1, 0.2, 0.3],
				alpha: 0.7
			)
			#expect(c.red == 0.1)
			#expect(c.green == 0.2)
			#expect(c.blue == 0.3)
			#expect(c.opacity == 0.7)
			#expect(c.isLinear == true)
		}
		
		@Test("Components initialized with an array of 4+ elements is using only the first 3")
		func testComponentsArrayFourValuesUsesFirstThreeAndAlphaParameter() {
			let c = Color.ResolvedComponents(
				linear: false,
				components: [0.1, 0.2, 0.3, 0.9],
				alpha: 0.4
			)
			#expect(c.red == 0.1)
			#expect(c.green == 0.2)
			#expect(c.blue == 0.3)
			/// alpha parameter should be used, not 4th component
			#expect(c.opacity == 0.4)
		}
		
		@Test("Create from array of CGFloat")
		func testComponentsArrayCGFloat() {
			let cgComponents: [CGFloat] = [0.2, 0.4, 0.6]
			let c = Color.ResolvedComponents(
				linear: true,
				components: cgComponents,
				alpha: 0.9
			)
			#expect(c.red == 0.2)
			#expect(c.green == 0.4)
			#expect(c.blue == 0.6)
			#expect(c.opacity == 0.9)
			#expect(c.isLinear == true)
		}
		
		@Test("White and black static constants")
		func testWhiteAndBlackStaticConstants() {
			let white = Color.ResolvedComponents.white
			#expect(white.isLinear == false)
			#expect(white.red == 1.0)
			#expect(white.green == 1.0)
			#expect(white.blue == 1.0)
			#expect(white.opacity == 1.0)
			
			let black = Color.ResolvedComponents.black
			#expect(black.isLinear == false)
			#expect(black.red == 0.0)
			#expect(black.green == 0.0)
			#expect(black.blue == 0.0)
			#expect(black.opacity == 1.0)
		}
	}
	
	// MARK: - ResolvedComponents derived properties
	
	@Suite("Color.ResolvedComponents Derived Properties")
	struct ResolvedComponentsDerivedTests {
		@Test("sRGB to linear conversion: flag and values")
		func testSRGBToLinearComponentsFlagAndValues() {
			let sRGB = Color.ResolvedComponents(
				linear: false,
				red: 0.5,
				green: 0.4,
				blue: 0.3,
				opacity: 1.0
			)
			
			let linear = sRGB.sRGBToLinearWCAG21
			#expect(linear.isLinear == true)
			#expect(abs(linear.red - 0.5.sRGBToLinearLightWCAG21) < ColorBrightnessLuminanceTests.epsilon)
			#expect(abs(linear.green - 0.4.sRGBToLinearLightWCAG21) < ColorBrightnessLuminanceTests.epsilon)
			#expect(abs(linear.blue - 0.3.sRGBToLinearLightWCAG21) < ColorBrightnessLuminanceTests.epsilon)
			#expect(linear.opacity == sRGB.opacity)
		}
		
		@Test("Luminescence matching for sRGB and linear colors")
		func testLuminanceMatchesBetweenSRGBAndLinear() {
			let sRGB = Color.ResolvedComponents(
				linear: false,
				red: 0.25,
				green: 0.5,
				blue: 0.75,
				opacity: 1.0
			)
			
			let linear = Color.ResolvedComponents(
				linear: true,
				red: 0.25.sRGBToLinearLightWCAG21,
				green: 0.5.sRGBToLinearLightWCAG21,
				blue: 0.75.sRGBToLinearLightWCAG21,
				opacity: 1.0
			)
			
			let sRGBLum = sRGB.luminance
			let linearLum = linear.luminance
			#expect(abs(sRGBLum - linearLum) < 1e-4)
		}
		
		@Test("Brightness matching for sRGB and linear colors")
		func testBrightnessMatchesBetweenSRGBAndLinear() {
			let sRGB = Color.ResolvedComponents(
				linear: false,
				red: 0.25,
				green: 0.5,
				blue: 0.75,
				opacity: 1.0
			)
			
			let linear = Color.ResolvedComponents(
				linear: true,
				red: 0.25.sRGBToLinearLightWCAG21,
				green: 0.5.sRGBToLinearLightWCAG21,
				blue: 0.75.sRGBToLinearLightWCAG21,
				opacity: 1.0
			)
			
			let sRGBBrightness = sRGB.brightness
			let linearBrightness = linear.brightness
			#expect(abs(sRGBBrightness - linearBrightness) < 1e-4)
		}
		
		@Test("Luminance for black and white")
		func testLuminanceForBlackAndWhite() {
			let black = Color.ResolvedComponents.black
			let white = Color.ResolvedComponents.white
			
			#expect(abs(black.luminance - 0.0) < ColorBrightnessLuminanceTests.epsilon)
			#expect(abs(white.luminance - 1.0) < 1e-4)
		}
		
		@Test("Brightness for black and white")
		func testBrightnessForBlackAndWhite() {
			let black = Color.ResolvedComponents.black
			let white = Color.ResolvedComponents.white
			
			#expect(abs(black.brightness - 0.0) < ColorBrightnessLuminanceTests.epsilon)
			#expect(abs(white.brightness - 1.0) < 1e-4)
		}
		
		@Test("Clamping all channels to [0, 1] using `zeroOneClipped`")
		func testZeroOneClippedClampsAllChannels() {
			let components = Color.ResolvedComponents(
				linear: true,
				red: -0.1,
				green: 0.3,
				blue: 1.2,
				opacity: 1.5
			)
			
			let clipped = components.zeroOneClipped
			#expect(clipped.isLinear == components.isLinear)
			#expect(clipped.red == 0.0)
			#expect(clipped.green == 0.3)
			#expect(clipped.blue == 1.0)
			#expect(clipped.opacity == 1.0)
		}
	}
	
	// MARK: - Representation enum
	
	@Suite("Color.ResolvedComponents.Representation Tests")
	struct RepresentationEnumTests {
		@Test("Representation: hashability and cases")
		func testRepresentationHashabilityAndCases() {
			let all: Set<Color.ResolvedComponents.Representation> = [.sRGB, .WCAG21]
			#expect(all.count == 2)
			#expect(all.contains(.sRGB))
			#expect(all.contains(.WCAG21))
		}
	}
	
	// MARK: - Color.Resolved extensions
	
	@Suite("Color.Resolved Extensions")
	struct ColorResolvedExtensionsTests {
		@Test("Resolved components from resolved color")
		func testResolvedComponentsFromResolvedColor() {
			let env = EnvironmentValues()
			let color: Color = .red
			
			let resolved = color.resolve(in: env)
			let components = resolved.resolvedComponents
			
			#expect(components.isLinear == false)
			#expect(components.opacity == 1.0)
			#expect(components.red >= 0.0 && components.red <= 1.0)
			#expect(components.green >= 0.0 && components.green <= 1.0)
			#expect(components.blue >= 0.0 && components.blue <= 1.0)
		}
		
		@Test("Resolved linear components from resolved color")
		func testLinearResolvedComponentsFromResolvedColor() {
			let env = EnvironmentValues()
			let color: Color = .red
			
			let resolved = color.resolve(in: env)
			let sRGBComponents = resolved.resolvedComponents
			let linearComponents = resolved.linearResolvedComponents
			
			#expect(linearComponents.isLinear == true)
			#expect(linearComponents.opacity == sRGBComponents.opacity)
			
			/// Luminance should approximately match between sRGB+linearization and pure linear.
			let sRGBLum = sRGBComponents.luminance
			let linearLum = linearComponents.luminance
			#expect(abs(sRGBLum - linearLum) < 1e-4)
		}
	}
	
	// MARK: - Color top-level helpers (Environment-based)
	
	@Suite("Color Environment-based Helpers")
	struct ColorEnvironmentHelpersTests {
		@Test("White and black resolved components")
		func testResolvedComponentsForWhiteAndBlack() {
			let env = EnvironmentValues()
			
			let whiteComponents = Color.resolvedComponents(of: .white, in: env)
			#expect(whiteComponents.opacity == 1.0)
			#expect(whiteComponents.red > 0.9)
			#expect(whiteComponents.green > 0.9)
			#expect(whiteComponents.blue > 0.9)
			
			let blackComponents = Color.resolvedComponents(of: .black, in: env)
			#expect(blackComponents.opacity == 1.0)
			#expect(blackComponents.red < 0.1)
			#expect(blackComponents.green < 0.1)
			#expect(blackComponents.blue < 0.1)
		}
		
		@Test("Relative luminance static and instance match")
		func testRelativeLuminanceStaticAndInstanceMatch() {
			let env = EnvironmentValues()
			
			let color: Color = .gray
			let staticLum = Color.luminance(of: color, in: env)
			let instanceLum = color.luminance(in: env)
			
			#expect(abs(staticLum - instanceLum) < ColorBrightnessLuminanceTests.epsilon)
			
			/// Sanity: gray should be between black and white.
			let blackLum = Color.luminance(of: .black, in: env)
			let whiteLum = Color.luminance(of: .white, in: env)
			#expect(blackLum < staticLum && staticLum < whiteLum)
		}
		
		@Test("Static brightness matches instance brightness")
		func testBrightnessStaticAndInstanceMatch() {
			let env = EnvironmentValues()
			
			let color: Color = .blue
			let staticBrightness = Color.brightness(of: color, in: env)
			let instanceBrightness = color.brightness(in: env)
			
			#expect(abs(staticBrightness - instanceBrightness) < ColorBrightnessLuminanceTests.epsilon)
			
			/// Sanity: brightness ordering for black < blue < white.
			let blackBrightness = Color.brightness(of: .black, in: env)
			let whiteBrightness = Color.brightness(of: .white, in: env)
			#expect(blackBrightness < staticBrightness && staticBrightness < whiteBrightness)
		}
	}

	// MARK: - Opacity-affected luminance & brightness
	
	@Suite("Opacity-affected Luminance & Brightness")
	struct OpacityAffectedTests {
		@Test("Luminance (Opacity-Affected, Light Scheme)")
		func testLuminanceOpacityAffectedLightScheme() {
			var env = EnvironmentValues()
			env.colorScheme = .light
			
			/// half-transparent black over white
			let color = Color(white: 0.0, opacity: 0.5)
			
			let baseLum = color.luminance(in: env, opacityAffected: false)
			let compositeLum = color.luminance(in: env, opacityAffected: true)
			
			#expect(abs(baseLum - 0.0) < ColorBrightnessLuminanceTests.epsilon)
			#expect(abs(compositeLum - 0.5) < 1e-4)
		}
		
		@Test("Luminance (Opacity-Affected, Dark Scheme)")
		func testLuminanceOpacityAffectedDarkScheme() {
			var env = EnvironmentValues()
			env.colorScheme = .dark
			
			/// half-transparent white over black
			let color = Color(white: 1.0, opacity: 0.5)
			
			let baseLum = color.luminance(in: env, opacityAffected: false)
			let compositeLum = color.luminance(in: env, opacityAffected: true)
			
			#expect(abs(baseLum - 1.0) < ColorBrightnessLuminanceTests.epsilon)
			#expect(abs(compositeLum - 0.5) < 1e-4)
		}
		
		@Test("Brightness (Opacity-Affected, Light Scheme)")
		func testBrightnessOpacityAffectedLightScheme() {
			var env = EnvironmentValues()
			env.colorScheme = .light
			
			let color = Color(white: 0.0, opacity: 0.5)
			
			let baseBrightness = color.brightness(in: env, opacityAffected: false)
			let compositeBrightness = color.brightness(in: env, opacityAffected: true)
			
			#expect(abs(baseBrightness - 0.0) < ColorBrightnessLuminanceTests.epsilon)
			#expect(abs(compositeBrightness - 0.5) < 1e-4)
		}
		
		@Test("Brightness (Opacity-Affected, Dark Scheme)")
		func testBrightnessOpacityAffectedDarkScheme() {
			var env = EnvironmentValues()
			env.colorScheme = .dark
			
			let color = Color(white: 1.0, opacity: 0.5)
			
			let baseBrightness = color.brightness(in: env, opacityAffected: false)
			let compositeBrightness = color.brightness(in: env, opacityAffected: true)
			
			#expect(abs(baseBrightness - 1.0) < ColorBrightnessLuminanceTests.epsilon)
			#expect(abs(compositeBrightness - 0.5) < 1e-4)
		}
	}
	
	// MARK: - Color.ResolvedHDR extensions (HDR path)
	
	#if RESOLVED_HDR_AVAILABLE
	@Suite("Color.ResolvedHDR Extensions (HDR Available)")
	struct ColorResolvedHDRExtensionsTests {
		@Test("ResolvedHDR Components for White")
		func testResolvedHDRComponentsForWhite() throws {
			/// Only run on platforms where the HDR API is available at runtime.
			if #available(iOS 26.0, macOS 26.0, *) {
				let env = EnvironmentValues()
				let resolvedHDR = Color.white.resolveHDR(in: env)
				let components = resolvedHDR.resolvedComponents
				let linearComponents = resolvedHDR.linearResolvedComponents
				
				/// sRGB components should be near white, linear flag should be false.
				#expect(components.isLinear == false)
				#expect(components.opacity == 1.0)
				#expect(components.red > 0.9)
				#expect(components.green > 0.9)
				#expect(components.blue > 0.9)
				
				/// Linear components should match linearization of sRGB components.
				#expect(linearComponents.isLinear == true)
				#expect(abs(linearComponents.red - components.red.sRGBToLinearLightWCAG21) < 1e-4)
				#expect(abs(linearComponents.green - components.green.sRGBToLinearLightWCAG21) < 1e-4)
				#expect(abs(linearComponents.blue - components.blue.sRGBToLinearLightWCAG21) < 1e-4)
				#expect(linearComponents.opacity == components.opacity)
			}
		}
	}
	#endif
}

#else

#warning("Color+brightness+luminance tests require Swift 6.2 or later with Testing framework availability. Tests are unavailable on this configuration.")

#endif
