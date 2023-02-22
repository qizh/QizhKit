//
//  Transaction+constants.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 22.02.23.
//  Copyright © 2023 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension Transaction {
	/// Will disable defined animations and use the one provided if any
	public static func withAnimationsReplaced(with animation: Animation) -> Transaction {
		var transaction = Transaction(animation: animation)
		transaction.disablesAnimations = true
		return transaction
	}
	
	/// Will disable defined animations
	public static var withAnimationsDisabled: Transaction {
		var transaction = Transaction()
		transaction.disablesAnimations = true
		return transaction
	}
}

extension Transaction {
	@available(*, deprecated, renamed: "withAnimationsDisabled")
	public static var withNoAnimations: Transaction {
		var transaction = Transaction()
		transaction.disablesAnimations = true
		return transaction
	}
}
