//
//  Pointer+sugar.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 13.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension UnsafePointer {
	var raw: UnsafeRawPointer { .init(self) }
	var mutable: UnsafeMutablePointer<Pointee> { .init(mutating: self) }
	func buffer(n: Int) -> UnsafeBufferPointer<Pointee> { .init(start: self, count: n) }
}

public extension UnsafeMutablePointer {
	var raw: UnsafeMutableRawPointer { .init(self) }
	func buffer(n: Int) -> UnsafeMutableBufferPointer<Pointee> { .init(start: self, count: n) }
	func advanced(by n: Int, wordSize: Int) -> UnsafeMutableRawPointer {
		raw.advanced(by: n * wordSize)
	}
}
