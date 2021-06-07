//
//  Data+string.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.09.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Hex

extension Data {
	public struct HexEncodingOptions: OptionSet {
		public let rawValue: Int
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
		public static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
	}
	
	public func hexEncodedString(options: HexEncodingOptions = []) -> String {
		let hexDigits = Array(
			(options.contains(.upperCase)
				? "0123456789ABCDEF"
				: "0123456789abcdef"
			).utf16
		)
		
		var chars: [unichar] = []
		chars.reserveCapacity(count.doubled)
		
		for byte in self {
			chars.append(hexDigits[Int(byte / 16)])
			chars.append(hexDigits[Int(byte % 16)])
		}
		
		return String(utf16CodeUnits: chars, count: chars.count)
	}
	
	public init?(hexString: String) {
		let len = hexString.count / 2
		var data = Data(capacity: len)
		for i in 0 ..< len {
			let j = hexString.index(hexString.startIndex, offsetBy: i * 2)
			let k = hexString.index(j, offsetBy: 2)
			let bytes = hexString[j ..< k]
			if var num = UInt8(bytes, radix: 16) {
				data.append(&num, count: 1)
			} else {
				return nil
			}
		}
		self = data
	}
}

// MARK: String

extension Data {
	public func asString(encoding: String.Encoding) -> String? {
		String(data: self, encoding: encoding)
	}
}
