//
//  Locale+preferences.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 24.09.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Locale {
	/// An array of `Locale.preferredLanguages` with country part cut off.
	/// - Experiment: Will return `en` for `en-US` or `en_US` language.
	public static var preferredLanguageISOCodes: [String] {
		preferredLanguages
			.map { lang in
				/// Language could be `en-US`, cutting out the `-US` part.
				lang
					.deleting(.starting(with: .first, .minus))
				/// I thought language could be `en_US` and was cutting out the `_US` part.
				/// But it looks like the standard separator is with `-`.
				// .deleting(.starting(with: .first, .underscore))
			}
			.filter { code in
				code.count == 2
			}
	}
}
