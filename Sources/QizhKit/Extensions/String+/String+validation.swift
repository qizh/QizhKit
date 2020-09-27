//
//  String+emailValidation.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 06.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public struct StringValidationExpression:
	ExpressibleByStringLiteral,
	CustomStringConvertible
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
	
	@inlinable func contains(no set: CharacterSet) -> Bool {
		rangeOfCharacter(from: set).isNotSet
	}
}
