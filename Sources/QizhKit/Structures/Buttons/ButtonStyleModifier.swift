//
//  ButtonStyleModifier.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 27.11.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Protocols

/// Opt-in capability for `ButtonStyle` types
/// that need to know whether the control is enabled.
///
/// When a style conforms to this protocol, `ButtonStyleModifier` injects the current
/// environment value of `isEnabled` into the style before applying it, allowing the style
/// to change appearance or behavior based on enabled/disabled state.
/// - Note: This value mirrors `Environment(\.isEnabled)`.
public protocol ButtonStyleDisableable {
	var isEnabled: Bool { get set }
}

/// Opt-in capability for `ButtonStyle` types
/// that adapt to the current color scheme.
///
/// When adopted, `ButtonStyleModifier` provides the environment `colorScheme` so the style
/// can tailor rendering for light or dark mode.
/// - Note: This value mirrors `Environment(\.colorScheme)`.
public protocol ButtonStyleColorSchemeDependable {
	var colorScheme: ColorScheme { get set }
}

/// Opt-in capability for `ButtonStyle` types
/// that render with a highlight accent color.
///
/// When adopted, `ButtonStyleModifier` supplies the environment `highlightColor` which a
/// style may use for pressed, focused, or emphasized states.
/// - Note: This value mirrors `Environment(\.highlightColor)` and can be `nil`.
public protocol ButtonStyleHighlighted {
	var highlightColor: Color? { get set }
}

/// Opt-in capability for `ButtonStyle` types
/// that reflect a selected state.
///
/// When adopted, `ButtonStyleModifier` injects the environment `selected` flag
/// so the style can visually indicate selection.
/// - Note: This value mirrors `Environment(\.selected)`.
public protocol ButtonStyleSelectable {
	var selected: Bool { get set }
}

/// Opt-in capability for `ButtonStyle` types
/// that depend on the current environment `font`.
///
/// When adopted, `ButtonStyleModifier` provides the environment `font` for
/// typography-aware sizing, spacing, or styling decisions.
/// - Note: This value mirrors `Environment(\.font)` and can be `nil`.
public protocol ButtonStyleCurrentFontAware {
	var font: Font? { get set }
}

/// Opt-in capability for `ButtonStyle` types
/// that respond to hover interactions.
///
/// When adopted, `ButtonStyleModifier` updates `isHovering` as the pointer enters or
/// leaves the view area, enabling hover-specific visuals.
/// - Note: This value is tracked by the modifier via `.onHover` and is not a standard
///   environment value.
public protocol ButtonStyleHoverable {
	var isHovering: Bool { get set }
}

/// Opt-in capability for `ButtonStyle` types
/// that should render placeholder/redacted states.
///
/// When adopted, `ButtonStyleModifier` sets `isPlaceholder` based on the current
/// redaction reasons (e.g., `redactionReasons.contains(.placeholder)`).
/// - Note: Driven by `Environment(\.redactionReasons)`.
public protocol ButtonStylePlaceholderable {
	var isPlaceholder: Bool { get set }
}

/// Opt-in capability for `ButtonStyle` types
/// that require pixel-accurate layout or strokes.
///
/// When adopted, `ButtonStyleModifier` provides `pixelLength` (the size of one pixel in
/// the current display scale) to help align borders and hairlines crisply.
/// - Note: This value mirrors `Environment(\.pixelLength)`.
public protocol ButtonStyleKnowingPixelLength {
	var pixelLength: CGFloat { get set }
}

/// Opt-in capability for `ButtonStyle` types
/// that need direct read-only access to the full set of SwiftUI `EnvironmentValues`.
///
/// When a style adopts this protocol, ``ButtonStyleModifier`` injects the current
/// `EnvironmentValues` into the style before applying it. This enables advanced styles
/// to consult multiple environment keys dynamically (beyond the specific values
/// supported by other opt-in protocols) and make rendering decisions accordingly.
/// ## Typical use cases include:
/// - Inspecting layout direction, size category, or dynamic type settings
/// - Respecting accessibility preferences and motion settings
/// - Coordinating with custom environment keys your app defines
/// ## Provided by
/// ``ButtonStyleModifier`` via `@Environment(\.self)`
/// - Important: Treat the provided `environmentValues` as read-only context for deriving
///   appearance and behavior. Mutating environment values should be done at the view
///   level, not within a `ButtonStyle`.
/// - SeeAlso:
///   - ``ButtonStyleDisableable``
///   - ``ButtonStyleColorSchemeDependable``
///   - ``ButtonStyleHighlighted``
///   - ``ButtonStyleSelectable``
///   - ``ButtonStyleCurrentFontAware``
///   - ``ButtonStyleHoverable``
///   - ``ButtonStylePlaceholderable``
///   - ``ButtonStyleKnowingPixelLength``
@MainActor public protocol ButtonStyleEnvironmentValuesAccessible {
	var environmentValues: EnvironmentValues { get set }
}

// MARK: - Button Style View Modifier

/// A `ViewModifier` that applies a given `ButtonStyle` to content
/// while enriching the style with relevant environment-driven context
/// when the style opts in.
///
/// ``ButtonStyleModifier`` acts as a bridge between `SwiftUI`’s environment and custom
/// `ButtonStyle` implementations. When the provided style conforms to one or more optional
/// “capability” protocols, this modifier injects the corresponding environment values into
/// a mutable copy of the style before applying it to the content.
///
/// ## Enriched environment/context values
/// | Protocol `ButtonStyle` conforms to | Value it receives | Source of Value |
/// |------------------------------------|-------------------|-----------------|
/// |``ButtonStyleDisableable``|``ButtonStyleDisableable/isEnabled``|`EnvironmentValues`|
/// |``ButtonStyleColorSchemeDependable``|``ButtonStyleColorSchemeDependable/colorScheme`` |`EnvironmentValues`|
/// |``ButtonStyleHighlighted``|``ButtonStyleHighlighted/highlightColor``|`EnvironmentValues`|
/// |``ButtonStyleSelectable``|``ButtonStyleSelectable/selected`` state |`EnvironmentValues`|
/// |``ButtonStyleCurrentFontAware``| ``ButtonStyleCurrentFontAware/font``|`EnvironmentValues`|
/// |``ButtonStyleHoverable``|``ButtonStyleHoverable/isHovering``|Tracked by the ``ButtonStyleModifier``|
/// |``ButtonStylePlaceholderable``|``ButtonStylePlaceholderable/isPlaceholder``|Derived from `redactionReasons.contains(.placeholder)`|
/// |``ButtonStyleKnowingPixelLength``|``ButtonStyleKnowingPixelLength/pixelLength`` |`EnvironmentValues`|
/// |``ButtonStyleEnvironmentValuesAccessible`` |``ButtonStyleEnvironmentValuesAccessible/environmentValues`` |`EnvironmentValues`|
/// ## Behavior
/// - The modifier listens for hover events via `.onHover` and updates `isHovering`,
///   which is forwarded to styles that adopt ``ButtonStyleHoverable``.
/// - Environment values are read using `@Environment` and conditionally injected into
///   the style through safe downcasts to the optional capability protocols.
/// - If the provided style does not adopt a given protocol, that environment value
///   is ignored.
/// ## Usage
/// ### Apply
/// - Via the convenience API on `ViewModifier`
///   ```swift
///   content.modifier(.buttonStyle(MyStyle()))
///   ```
/// - Direct initialization
///   ```swift
///   ButtonStyleModifier(style:)
///   ```
/// This is especially useful for custom button styles that should adapt to light/dark
/// mode, enabled state, hover/selection interactions, placeholder redaction,
/// or pixel-accurate rendering.
/// ## Considerations
///   - The modifier updates a mutable copy of the style in order to inject the environment
///     values, then applies the updated style with `.buttonStyle(_:)`.
///   - Hover tracking is local to this modifier, ensuring hover state is available
///     even if the environment does not directly provide it.
///   - This approach keeps button styles lightweight and focused while allowing them to
///     react to a wide range of environment-driven changes without manual wiring in each
///     usage site.
/// - Note: The surrounding extension that provides `.buttonStyle(_:)` as a `ViewModifier`
///   factory is annotated with `@MainActor` to ensure UI updates occur on the main thread.
/// - SeeAlso:
///   - ``ButtonStyleDisableable``
///   - ``ButtonStyleColorSchemeDependable``
///   - ``ButtonStyleHighlighted``
///   - ``ButtonStyleSelectable``
///   - ``ButtonStyleCurrentFontAware``
///   - ``ButtonStyleHoverable``
///   - ``ButtonStylePlaceholderable``
///   - ``ButtonStyleKnowingPixelLength``
///   - ``ButtonStyleEnvironmentValuesAccessible``
public struct ButtonStyleModifier<Style: ButtonStyle>: ViewModifier {
	@Environment(\.isEnabled) 			private var isEnabled: Bool
	@Environment(\.colorScheme) 		private var colorScheme: ColorScheme
	@Environment(\.highlightColor) 		private var highlightColor: Color?
	@Environment(\.selected) 			private var selected: Bool
	@Environment(\.font) 				private var font: Font?
	@Environment(\.redactionReasons) 	private var redactionReasons: RedactionReasons
	@Environment(\.pixelLength) 		private var pixelLength: CGFloat
	@Environment(\.self) 				private var environmentValues: EnvironmentValues
	
	@State private var isHovering: Bool = false
	
	private let style: Style
	
	// MARK: ┣ Init
	
	/// Creates a `ButtonStyleModifier` that applies the given `ButtonStyle`
	/// to the content.
	///
	/// `ButtonStyleModifier` is enriching the style with relevant environment-driven
	/// values when the style type opts into them via the optional capability protocols.
	/// - Remark:
	///   ### Enriching `ButtonStyle`
	///   The modifier will conditionally inject environment values such as `isEnabled`,
	///   `colorScheme`, `highlightColor`, `selected`, `font`,
	///   `redaction` (`placeholder`) state, hover state, and `pixelLength`
	///   into a mutable copy of the provided style before applying it,
	///   when the style conforms to the corresponding protocols:
	///   - ``ButtonStyleDisableable``: receives `isEnabled`
	///   - ``ButtonStyleColorSchemeDependable``: receives `colorScheme`
	///   - ``ButtonStyleHighlighted``: receives `highlightColor`
	///   - ``ButtonStyleSelectable``: receives `selected`
	///   - ``ButtonStyleCurrentFontAware``: receives `font`
	///   - ``ButtonStyleHoverable``: receives `isHovering`
	///     (tracked by the modifier)
	///   - ``ButtonStylePlaceholderable``: receives `isPlaceholder`
	///     (from `redaction` `reasons`)
	///   - ``ButtonStyleKnowingPixelLength``: receives `pixelLength`
	/// - Parameter style: The `ButtonStyle` to apply and enrich with environment context.
	/// - Note: Hover state is tracked internally by the modifier and provided to styles
	///   that adopt `ButtonStyleHoverable`.
	///   Other values are read from the SwiftUI environment.
	/// - SeeAlso:
	///   - ``ButtonStyleDisableable``
	///   - ``ButtonStyleColorSchemeDependable``
	///   - ``ButtonStyleHighlighted``
	///   - ``ButtonStyleSelectable``
	///   - ``ButtonStyleCurrentFontAware``
	///   - ``ButtonStyleHoverable``
	///   - ``ButtonStylePlaceholderable``
	///   - ``ButtonStyleKnowingPixelLength``
	///   - ``ButtonStyleEnvironmentValuesAccessible``
	public init(style: Style) {
		self.style = style
	}
	
	// MARK: ┣ .for(_:)
	
	/// Creates a `ButtonStyleModifier` that applies and enriches the given `ButtonStyle`.
	///
	/// This convenience constructor mirrors the initializer and returns a modifier
	/// configured with the provided style. Before being applied, the style will be
	/// conditionally enriched with environment-driven values when it conforms to the
	/// corresponding capability protocols:
	/// - ``ButtonStyleDisableable``: injects `isEnabled`
	/// - ``ButtonStyleColorSchemeDependable``: injects `colorScheme`
	/// - ``ButtonStyleHighlighted``: injects `highlightColor`
	/// - ``ButtonStyleSelectable``: injects `selected`
	/// - ``ButtonStyleCurrentFontAware``: injects `font`
	/// - ``ButtonStyleHoverable``: injects `isHovering` (tracked by the modifier)
	/// - ``ButtonStylePlaceholderable``: injects `isPlaceholder`
	///   (from `redaction` `reasons`)
	/// - ``ButtonStyleKnowingPixelLength``: injects `pixelLength`
	/// - Precondition:
	///   Use this when you want a concise, fluent way to obtain a `ButtonStyleModifier`
	///   for a given style without explicitly writing the initializer.
	/// - Parameter style: The `ButtonStyle` to apply and enrich with environment context.
	/// - Returns: A `ButtonStyleModifier` configured to apply the provided style,
	///   enriched with relevant environment values when supported by the style type.
	/// - SeeAlso:
	///   - ``init(style:)``
	///   - ``ButtonStyleDisableable``
	///   - ``ButtonStyleColorSchemeDependable``
	///   - ``ButtonStyleHighlighted``
	///   - ``ButtonStyleSelectable``
	///   - ``ButtonStyleCurrentFontAware``
	///   - ``ButtonStyleHoverable``
	///   - ``ButtonStylePlaceholderable``
	///   - ``ButtonStyleKnowingPixelLength``
	///   - ``ButtonStyleEnvironmentValuesAccessible``
	@inlinable public static func `for`(_ style: Style) -> Self {
		.init(style: style)
	}
	
	// MARK: ┣ Body
	
	public func body(content: Content) -> some View {
		content
			.buttonStyle(updatedStyle())
			.onHover { hovering in
				isHovering = hovering
			}
	}
	
	// MARK: ┗ Style
	
	private func updatedStyle() -> Style {
		var updated = style
		
		var disablable = updated as? ButtonStyleDisableable
		disablable?.isEnabled = isEnabled
		updated = (disablable as? Style) ?? updated
		
		var colorSchemable = updated as? ButtonStyleColorSchemeDependable
		colorSchemable?.colorScheme = colorScheme
		updated = (colorSchemable as? Style) ?? updated
		
		var highlightColorable = updated as? ButtonStyleHighlighted
		highlightColorable?.highlightColor = highlightColor
		updated = (highlightColorable as? Style) ?? updated
		
		var selectable = updated as? ButtonStyleSelectable
		selectable?.selected = selected
		updated = (selectable as? Style) ?? updated
		
		var fontAware = updated as? ButtonStyleCurrentFontAware
		fontAware?.font = font
		updated = (fontAware as? Style) ?? updated
		
		var hoverable = updated as? ButtonStyleHoverable
		hoverable?.isHovering = isHovering
		updated = (hoverable as? Style) ?? updated
		
		var placeholderable = updated as? ButtonStylePlaceholderable
		placeholderable?.isPlaceholder = redactionReasons.contains(.placeholder)
		updated = (placeholderable as? Style) ?? updated
		
		var knowingPixelLength = updated as? ButtonStyleKnowingPixelLength
		knowingPixelLength?.pixelLength = pixelLength
		updated = (knowingPixelLength as? Style) ?? updated
		
		var envValuesAccessible = updated as? ButtonStyleEnvironmentValuesAccessible
		envValuesAccessible?.environmentValues = environmentValues
		updated = (envValuesAccessible as? Style) ?? updated
		
		return updated
	}
}

// MARK: ViewModifier+

@MainActor
extension ViewModifier {
	/// Applies a `ButtonStyle` to the modified view by wrapping it
	/// in a `ButtonStyleModifier` that propagates relevant environment values to styles
	/// that opt into them.
	///
	/// This convenience constructor is intended to be used
	/// via the `ViewModifier` extension as: `SomeView.modifier(.buttonStyle(MyStyle()))`,
	/// or when used as a type-constrained modifier in places
	/// where a concrete `ViewModifier` type is required.
	/// ## Enriching `ButtonStyle`
	/// Unlike directly calling `.buttonStyle(_:)` on a `View`, this modifier enriches the
	/// provided `ButtonStyle` with additional context taken from the SwiftUI environment,
	/// if the style type conforms to any of the following optional protocols:
	/// - ``ButtonStyleDisableable``: receives `isEnabled`
	/// - ``ButtonStyleColorSchemeDependable``: receives `colorScheme`
	/// - ``ButtonStyleHighlighted``: receives `highlightColor`
	/// - ``ButtonStyleSelectable``: receives `selected`
	/// - ``ButtonStyleCurrentFontAware``: receives `font`
	/// - ``ButtonStyleHoverable``: receives `isHovering`
	/// - ``ButtonStylePlaceholderable``: receives `isPlaceholder`
	///   based on `redaction` `reasons`
	/// - ``ButtonStyleKnowingPixelLength``: receives `pixelLength`
	/// ## Updating Style:
	/// The modifier updates a mutable copy of the provided style to inject these values
	/// when the style conforms to the respective protocol, then applies the resulting
	/// style to the content.
	/// ## Usage:
	///   - Prefer this when you want your custom `ButtonStyle`
	///     to react to environment-driven changes like color scheme, enabled state,
	///     hover, or redaction without manually wiring them up.
	///   - Your style may opt into any subset of the listed protocols
	///     to receive those values.
	///   - This is particularly useful for custom styles that need to render consistently
	///     across different environments (light/dark mode), accessibility states
	///     (placeholder redaction), and interaction states (hover, selection).
	/// - Parameter style: The `ButtonStyle` to apply to the content.
	/// - Returns: A `ButtonStyleModifier` configured with the provided style,
	///   enriched with environment-driven state when supported by the style type.
	/// - Note:
	///   - The enrichment is performed dynamically via conditional casting.
	///     - if the style does not conform to a protocol, that value is simply ignored.
	///   - Hover state is tracked internally by the modifier and provided to styles
	///     that adopt `ButtonStyleHoverable`.
	///   - The modifier is annotated `@MainActor` via the surrounding extension
	///     to ensure UI updates occur on the main thread.
	@inlinable public static func buttonStyle<S>(
		_ style: S
	) -> ButtonStyleModifier<S> where S: ButtonStyle, Self == ButtonStyleModifier<S> {
		.for(style)
	}
}
