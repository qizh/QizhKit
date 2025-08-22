//
//  String+asTreeBranches.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 24.12.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import Foundation
import OrderedCollections

// MARK: String surround by

extension String {
	/// `┣ ...`
	@inlinable public var prefixedAsTreeBranch: String {
		"┣ \(self)"
	}
	
	/// `┗ ...`
	@inlinable public var prefixedAsLastTreeBranch: String {
		"┗ \(self)"
	}
	
	/// `┣ name: ...`
	@inlinable public func asTreeBranch(named name: String) -> String {
		"┣ \(name): \(self)"
	}
	
	/// `┗ name: ...`
	@inlinable public func asTreeLastBranch(named name: String) -> String {
		"┗ \(name): \(self)"
	}
}

// MARK: Collection

extension Collection<String> {
	/// Will output tree like the following:
	/// ```
	/// ┣ value1
	/// ┣ value2
	/// ┗ value3
	/// ```
	public var asTreeBranches: String {
		if isEmpty { return .empty }
		if let justOne { return justOne.prefixedAsLastTreeBranch }
		
		var output: String = .empty
		for (index, string) in self.enumerated() {
			if index == count - 1 {
				output += string.prefixedAsLastTreeBranch
			} else {
				output += string.prefixedAsTreeBranch + .newLine
			}
		}
		return output
	}
	
	/// Will output tree like the following:
	/// ```
	/// name
	/// ┣ value1
	/// ┣ value2
	/// ┗ value3
	/// ```
	/// or `name: <empty>` in case of empty collection
	public func asTreeBranches(named name: String) -> String {
		if isEmpty {
			"\(name): <empty>"
		} else {
			"""
			\(name)
			\(asTreeBranches)
			"""
		}
	}
	
	/// Will output tree like the following:
	/// ```
	/// ┣ 0: value1
	/// ┣ 1: value2
	/// ┗ 2: value3
	/// ```
	@inlinable public var asNumberedTreeBranches: String {
		asEnumeratedOrderedDictionary.asTreeBranches
	}
	
	/// Will output tree like the following:
	/// ```
	/// name
	/// ┣ 0: value1
	/// ┣ 1: value2
	/// ┗ 2: value3
	/// ```
	/// or `name: <empty>` in case of empty Dictionary
	@inlinable public func asNumberedTreeBranches(named name: String) -> String {
		asEnumeratedOrderedDictionary.asTreeBranches(named: name)
	}
	
	/// `value 1 → value 2 → value 3`
	public var asArrowedPath: String {
		if isEmpty {
			.empty
		} else if let justOne {
			justOne
		} else {
			joined(separator: .spaceArrowSpace)
		}
	}
}

extension Collection where Element: CustomStringConvertible {
	/// Will output tree like the following:
	/// ```
	/// ┣ value1
	/// ┣ value2
	/// ┗ value3
	/// ```
	@inlinable public var asTreeBranches: String {
		descriptions.asTreeBranches
	}
	
	/// Will output tree like the following:
	/// ```
	/// name
	/// ┣ value1
	/// ┣ value2
	/// ┗ value3
	/// ```
	/// or `name: <empty>` in case of empty collection
	public func asTreeBranches(named name: String) -> String {
		descriptions.asTreeBranches(named: name)
	}
	
	/// Will output tree like the following:
	/// ```
	/// ┣ 0: value1
	/// ┣ 1: value2
	/// ┗ 2: value3
	/// ```
	@inlinable public var asNumberedTreeBranches: String {
		descriptions.asEnumeratedOrderedDictionary.asTreeBranches
	}
	
	/// Will output tree like the following:
	/// ```
	/// name
	/// ┣ 0: value1
	/// ┣ 1: value2
	/// ┗ 2: value3
	/// ```
	/// or `name: <empty>` in case of empty Dictionary
	@inlinable public func asNumberedTreeBranches(named name: String) -> String {
		descriptions.asEnumeratedOrderedDictionary.asTreeBranches(named: name)
	}
}

// MARK: Dictionary

extension Dictionary where Key: Hashable, Value == String {
	/// Will output tree like the following:
	/// ```
	/// ┣ key1: value1
	/// ┣ key2: value2
	/// ┗ key3: value3
	/// ```
	public var asTreeBranches: String {
		if isEmpty { return .empty }
		if let justOne { return justOne.value.asTreeLastBranch(named: "\(justOne.key)") }
		
		var outputs: [String] = .empty
		for (index, (key, value)) in self.enumerated() {
			if index == count - 1 {
				outputs.append(value.asTreeLastBranch(named: "\(key)"))
			} else {
				outputs.append(value.asTreeBranch(named: "\(key)"))
			}
		}
		return outputs.joined(separator: .newLine)
	}
	
	/// Will output tree like the following:
	/// ```
	/// name
	/// ┣ key1: value1
	/// ┣ key2: value2
	/// ┗ key3: value3
	/// ```
	/// or `name: <empty>` in case of empty Dictionary
	public func asTreeBranches(named name: String) -> String {
		if isEmpty {
			"\(name): <empty>"
		} else {
			"""
			\(name)
			\(asTreeBranches)
			"""
		}
	}
}

extension Dictionary where Key: Hashable, Value: CustomStringConvertible {
	/// Will output tree like the following:
	/// ```
	/// ┣ key1: value1
	/// ┣ key2: value2
	/// ┗ key3: value3
	/// ```
	public var asTreeBranches: String {
		Dictionary<Key, String>(
			uniqueKeysWithValues: map({($0.key, $0.value.description)})
		)
		.asTreeBranches
	}
	
	/// Will output tree like the following:
	/// ```
	/// name
	/// ┣ key1: value1
	/// ┣ key2: value2
	/// ┗ key3: value3
	/// ```
	/// or `name: <empty>` in case of empty Dictionary
	public func asTreeBranches(named name: String) -> String {
		Dictionary<Key, String>(
			uniqueKeysWithValues: map({($0.key, $0.value.description)})
		)
		.asTreeBranches(named: name)
	}
}

// MARK: Ordered Dictionary

extension OrderedDictionary where Key: Hashable, Value == String {
	/// Will output tree like the following:
	/// ```
	/// ┣ key1: value1
	/// ┣ key2: value2
	/// ┗ key3: value3
	/// ```
	public var asTreeBranches: String {
		if isEmpty { return .empty }
		if let justOne = self.elements.justOne {
			return justOne.value.asTreeLastBranch(named: "\(justOne.key)")
		}
		
		var outputs: [String] = .empty
		for (index, (key, value)) in self.enumerated() {
			if index == count - 1 {
				outputs.append(value.asTreeLastBranch(named: "\(key)"))
			} else {
				outputs.append(value.asTreeBranch(named: "\(key)"))
			}
		}
		return outputs.joined(separator: .newLine)
	}
	
	/// Will output tree like the following:
	/// ```
	/// name
	/// ┣ key1: value1
	/// ┣ key2: value2
	/// ┗ key3: value3
	/// ```
	/// or `name: <empty>` in case of empty Dictionary
	public func asTreeBranches(named name: String) -> String {
		if isEmpty {
			"\(name): <empty>"
		} else {
			"""
			\(name)
			\(asTreeBranches)
			"""
		}
	}
}

extension OrderedDictionary where Key: Hashable, Value: CustomStringConvertible {
	/// Will output tree like the following:
	/// ```
	/// ┣ key1: value1
	/// ┣ key2: value2
	/// ┗ key3: value3
	/// ```
	public var asTreeBranches: String {
		OrderedDictionary<Key, String>(
			uniqueKeysWithValues: map({($0.key, $0.value.description)})
		)
		.asTreeBranches
	}
	
	/// Will output tree like the following:
	/// ```
	/// name
	/// ┣ key1: value1
	/// ┣ key2: value2
	/// ┗ key3: value3
	/// ```
	/// or `name: <empty>` in case of empty Dictionary
	public func asTreeBranches(named name: String) -> String {
		OrderedDictionary<Key, String>(
			uniqueKeysWithValues: map({($0.key, $0.value.description)})
		)
		.asTreeBranches(named: name)
	}
}
