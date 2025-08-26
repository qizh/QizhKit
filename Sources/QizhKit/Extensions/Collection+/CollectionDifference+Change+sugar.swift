//
//  CollectionDifference+Change+sugar.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.08.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension CollectionDifference.Change: @retroactive CustomStringConvertible {
	@inlinable public var offset: Int {
		switch self {
		case .insert(let offset, _, _),
			 .remove(let offset, _, _): offset
		}
	}
	
	@inlinable public var element: ChangeElement {
		switch self {
		case .insert(_, let element, _),
			 .remove(_, let element, _): element
		}
	}
	
	@inlinable public var associatedWith: Int? {
		switch self {
		case .insert(_, _, let associatedWith),
			 .remove(_, _, let associatedWith): associatedWith
		}
	}
	
	@inlinable public var caseName: String {
		switch self {
		case .insert: "insert"
		case .remove: "remove"
		}
	}
	
	public var description: String {
		"\(caseName)[\(offset)](\(element)\(map: associatedWith, ", associatedWith: $0")"
	}
}
