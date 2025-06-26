//
//  Collection+initializable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation
import SwiftUI

public protocol Initializable: Sendable {
	init()
}
public protocol InitializableCollection: Collection, Initializable, Sendable where Element: Sendable { }
public protocol InitializableWithSequenceCollection: Collection, Sendable where Element: Sendable {
	init<S: Sequence>(_ elements: S) where S.Element == Element
}

public extension InitializableCollection where Self: EmptyProvidable {
	static var empty: Self { .init() }
}

extension Array: InitializableWithSequenceCollection where Element: Sendable { }
extension Set: InitializableWithSequenceCollection where Element: Sendable { }
extension String: InitializableWithSequenceCollection { }

extension Array: InitializableCollection, EmptyProvidable where Element: Sendable { }
extension Set: InitializableCollection, EmptyProvidable where Element: Sendable { }
extension String: InitializableCollection, EmptyProvidable { }
extension Dictionary: InitializableCollection, EmptyProvidable where Key: Sendable, Value: Sendable { }

extension Bool: Initializable { }
extension Int: Initializable { }
extension UInt: Initializable { }
extension Float: Initializable { }
extension Double: Initializable { }
extension Decimal: Initializable { }
extension CGFloat: Initializable { }
extension CGPoint: Initializable { }
extension CGSize: Initializable { }
extension CGRect: Initializable { }
extension Date: Initializable { }
extension Data: Initializable { }

public protocol AnyElementCollection: Sendable {
	var anyFirst: Any { get }
	var elementType: Any.Type { get }
}

extension Array: AnyElementCollection where Element: Sendable {
	public var anyFirst: Any { first as Any }
	public var elementType: Any.Type { Element.self }
}
extension Set: AnyElementCollection where Element: Sendable {
	public var anyFirst: Any { first as Any }
	public var elementType: Any.Type { Element.self }
}
extension String: AnyElementCollection {
	public var anyFirst: Any { first as Any }
	public var elementType: Any.Type { Element.self }
}
extension Dictionary: AnyElementCollection where Key: Sendable, Value: Sendable {
	public var anyFirst: Any { first as Any }
	public var elementType: Any.Type { Element.self }
}
