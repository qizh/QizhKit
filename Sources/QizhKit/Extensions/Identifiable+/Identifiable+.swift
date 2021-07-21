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
public extension IdentifiableCaseIterable {
	var id: AllCases.Index {
		Self.allCases.firstIndex(of: self)
			?? Self.allCases.startIndex
	}
}

// MARK: + RawRepresentable

public protocol IdentifiableRawRepresentable: Identifiable, RawRepresentable { }
public extension IdentifiableRawRepresentable {
	var id: RawValue { rawValue }
}
