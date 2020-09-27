//
//  DemoError.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 20.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public enum DemoError: LocalizedError {
	case detailed(_ code: Int, _ message: String)
	case secret(_ code: Int)
	case cancelled
	
	public var errorDescription: String? {
		switch self {
		case .detailed(_, let message): return message
		case .secret(let code): 		return "Secret error #\(code)"
		case .cancelled: 				return "Operation cancelled"
		}
	}
	
	public static let superSecret: Self = .secret(42)
	public static let paymentMethodBelongs: Self = .detailed(50, "The `payment_method` parameter supplied pm_1H6QQPDAQNwPQYjpi3AKYHmS belongs to the Customer cus_HflyS4utzzKlr2. Please include the Customer in the `customer` parameter on the PaymentIntent.")
}
