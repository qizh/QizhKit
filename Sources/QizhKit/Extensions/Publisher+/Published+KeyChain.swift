//
//  Published+KeyChain.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 07.06.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation
import Combine

private var cancellables = Set<AnyCancellable>()

extension Published where Value == String {
	public init(
		wrappedValue defaultValue: Value,
		keychainKey: String
	) {
		let key = keychainKey.localizedLowercase.replacing(.whitespaces, with: .underline)
		if let data = KeyChain.data(for: key),
		   let string = String(data: data, encoding: .utf8) {
			self.init(initialValue: string)
		} else {
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				if let data = value.data(using: .utf8) {
					KeyChain.save(data, for: key)
				} else {
					KeyChain.remove(for: key)
				}
			}
			.store(in: &cancellables)
	}
}

extension Published where Value == String? {
	public init(
		wrappedValue defaultValue: Value,
		keychainKey: String
	) {
		let key = keychainKey.localizedLowercase.replacing(.whitespaces, with: .underline)
		if let data = KeyChain.data(for: key),
		   let string = String(data: data, encoding: .utf8) {
			self.init(initialValue: string)
		} else {
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				if let value = value,
				   let data = value.data(using: .utf8) {
					KeyChain.save(data, for: key)
				} else {
					KeyChain.remove(for: key)
				}
			}
			.store(in: &cancellables)
	}
}
