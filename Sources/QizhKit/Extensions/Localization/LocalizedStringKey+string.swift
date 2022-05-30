//
//  LocalizedStringKey.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 30.05.2022.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

/*
extension LocalizedStringKey {
	var stringKey: String? {
		Mirror(reflecting: self)
			.children
			.first { child in
				child.label == "key"
			}?
			.value
	}
}

extension String {
	static func localizedString(for key: String,
								locale: Locale = .current) -> String {
		
		let language = locale.languageCode
		let path = Bundle.main.path(forResource: language, ofType: "lproj")!
		let bundle = Bundle(path: path)!
		let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
		
		return localizedString
	}
}

extension LocalizedStringKey {
	func stringValue(locale: Locale = .current) -> String {
		return .localizedString(for: self.stringKey, locale: locale)
	}
}
*/
