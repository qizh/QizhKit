//
//  RelativePointer.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 13.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public struct RelativePointer<Offset: FixedWidthInteger, Pointee> {
	public var offset: Offset
	
	public mutating func pointee() -> Pointee { advanced().pointee }
	public mutating func advanced() -> UnsafeMutablePointer<Pointee> {
		let offset = self.offset
		return withUnsafePointer(to: &self) { p in
			p.raw
				.advanced(by: numericCast(offset))
				.assumingMemoryBound(to: Pointee.self)
				.mutable
		}
	}
}

public struct Vector<Element> {
	public var element: Element
	
	public mutating func vector(n: Int) -> UnsafeBufferPointer<Element> {
		withUnsafePointer(to: &self) {
			$0.withMemoryRebound(
				to: Element.self,
				capacity: 1
			) { start in
				start.buffer(n: n)
			}
		}
	}
	
	public mutating func element(at i: Int) -> UnsafeMutablePointer<Element> {
		withUnsafePointer(to: &self) {
			$0.raw
				.assumingMemoryBound(to: Element.self)
				.advanced(by: i)
				.mutable
		}
	}
}

public struct RelativeVectorPointer<Offset: FixedWidthInteger, Pointee> {
	public var offset: Offset
}
