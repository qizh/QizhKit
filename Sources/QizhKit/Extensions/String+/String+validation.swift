//
//  String+emailValidation.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 06.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct StringValidationExpression:
	ExpressibleByStringLiteral,
	CustomStringConvertible,
	Sendable
{
	public let description: String
	public init(_ value: String) { self.description = value }
	public init(stringLiteral value: String) { self.description = value }

	public static let email: Self = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,64}$"#
	
	/// https://webapps.stackexchange.com/questions/54443/format-for-id-of-youtube-video/101153#101153
	public static let youtubeVideoCode: Self = #"^[0-9A-Za-z_-]{10}[048AEIMQUYcgkosw]$"#
}

public extension String {
	@inlinable var isValidEmail: Bool { self.is(valid: .email) }
	@inlinable var isValidYouTubeCode: Bool { self.is(valid: .youtubeVideoCode) }
	// @available(iOSApplicationExtension, unavailable)
	@inlinable var isValidURL: Bool {
		URL(string: self)
			.map { url in
				UIApplication.shared.canOpenURL(url)
			}
			?? false
	}
}

public extension String {
	typealias ValidationExpression = StringValidationExpression
	@inlinable func `is`(valid expression: ValidationExpression) -> Bool {
		range(of: expression.description, options: .regularExpression) != nil
	}
}

public extension String {
	@inlinable func contains(_ set: CharacterSet) -> Bool {
		rangeOfCharacter(from: set).isSet
	}
	
	@inlinable func containsNo(_ set: CharacterSet) -> Bool {
		rangeOfCharacter(from: set).isNotSet
	}
	
	@available(*, deprecated, renamed: "containsNo(_:)", message: "Renamed to containsNo(_:) to avoid naming collisions with contains(_:)")
	@inlinable func contains(no set: CharacterSet) -> Bool {
		rangeOfCharacter(from: set).isNotSet
	}
}

// MARK: Emoji

public extension Character {
	/// A simple emoji is one scalar and presented to the user as an Emoji
	var isSimpleEmoji: Bool {
		guard let firstScalar = unicodeScalars.first else { return false }
		return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
	}

	/// Checks if the scalars will be merged into an emoji
	var isCombinedIntoEmoji: Bool {
			unicodeScalars.count > 1
		&& 	unicodeScalars.first?.properties.isEmoji
		?? false
	}
	
	var isEmoji: Bool {
			isSimpleEmoji
		|| 	isCombinedIntoEmoji
	}
}

public extension String {
	var isSingleEmoji: Bool { count == 1 && containsEmoji }
	var containsEmoji: Bool { contains { $0.isEmoji } }
	var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
	var emojiString: String { emojis.map { String($0) }.reduce("", +) }
	var emojis: [Character] { filter { $0.isEmoji } }
	var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}
