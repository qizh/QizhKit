//
//  Identifiable+.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 13.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: + CaseIterable

public protocol IdentifiableCaseIterable: Identifiable, CaseIterable, Equatable { }
extension IdentifiableCaseIterable {
	public var id: AllCases.Index {
		Self.allCases.firstIndex(of: self)
			?? Self.allCases.startIndex
	}
}

// MARK: + RawRepresentable

public protocol IdentifiableRawRepresentable: Identifiable, RawRepresentable { }
extension IdentifiableRawRepresentable {
	public var id: RawValue { rawValue }
}

// MARK: Collection -> ids

extension Collection where Element: Identifiable {
	@inlinable public var ids: [Element.ID] {
		map(\.id)
	}
}
