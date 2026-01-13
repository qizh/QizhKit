//
//  Bundle+forLocale.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 27.11.2023.
//  Copyright © 2023 Bespokely. All rights reserved.
//

public import Foundation

extension Bundle {
	/// Returns a bundle that best matches the given `Locale`, if available, falling back
	/// to broader language resources or the receiver.
	///
	/// ## Why this exists
	/// This helper is useful when you need to resolve localized resources for a specific
	/// locale independently of the app/system language — for example, to preview a locale,
	/// render server-provided content in a chosen language, or test translations. By
	/// returning a locale-specific bundle, you can pass it to APIs like
	/// `String(localized:bundle:)`, `Image.init(_:bundle:)`, or manual resource loading.
	///
	/// ## Strings Catalogs (`.xcstrings`)
	/// If your project uses Strings Catalogs, you usually do NOT need to manually switch
	/// bundles per locale for ordinary app localization — the system resolves the
	/// appropriate localization based on the user's settings. However, this method remains
	/// relevant when you intentionally want per-locale lookups regardless of the current
	/// system language (e.g., in settings screens or debug tooling). Strings Catalogs still
	/// compile into `.lproj` resources at build time, so resolving a locale-specific bundle
	/// via `.lproj` remains valid.
	///
	/// ## Resolution strategy
	/// The method attempts the following in order:
	/// 1. Exact identifier match (e.g., `"en-US"`, `"zh-Hant-TW"`) using the locale's
	///    canonical identifier.
	/// 2. Language-script-region fallbacks by progressively trimming components (e.g.,
	///    `"zh-Hant-TW"` → `"zh-Hant"` → `"zh"`).
	/// 3. Language-only code using `LanguageCode` (e.g., `"en"`).
	/// 4. Returns `self` if nothing matches.
	///
	/// - Note:
	///   - This relies on `.lproj` directories being present in the bundle.
	///   - Prefer one of the following methods with the returned bundle
	///     when you need explicit per-locale strings:
	///     - `String(localized:keyAndValue:bundle:table:)`
	///     - `String(localized:bundle:)`
	///     For normal app UI, rely on the system's selected language and don't call this.
	///   - Consider `Bundle.preferredLocalizations` and `Bundle.localizations` if you need
	///     to inspect availability.
	/// - Parameter locale: The target locale for resource resolution.
	/// - Returns: A `Bundle` matching the locale if possible, otherwise `self`.
	public func forLocale(_ locale: Locale) -> Bundle {
		/// Build a list of candidate identifiers to try, from most specific to least.
		/// Use canonical identifiers to align with `.lproj` naming conventions.
		var candidates: [String] = []
		let canonical = locale.identifier.trimmingCharacters(in: .whitespacesAndNewlines)
			.replacingOccurrences(of: "_", with: "-")
		if !canonical.isEmpty { candidates.append(canonical) }

		/// If identifier contains hyphen-separated parts, progressively trim components.
		/// ## For example
		/// ```swift
		/// "zh-Hant-TW" → "zh-Hant" → "zh"
		/// ```
		let parts = canonical.split(separator: .minus)
		if parts.count > 1 {
			for i in stride(from: parts.count - 1, through: 1, by: -1) {
				let trimmed = parts.prefix(i).joined(separator: "-")
				if !candidates.contains(trimmed) { candidates.append(trimmed) }
			}
		}

		// Add language-only fallback from Locale.Language if available.
		if let lang = locale.language.languageCode?.identifier, !lang.isEmpty, !candidates.contains(lang) {
			candidates.append(lang)
		}

		// Try to resolve an `.lproj` bundle for the first matching candidate.
		for id in candidates {
			if let path = self.path(forResource: id, ofType: "lproj"),
			   let b = Bundle(path: path) {
				return b
			}
		}

		return self
	}
}
