//
//  CLLocationCoordinate2D+Equatible.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 05.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: Equatable

extension CLLocationCoordinate2D: @retroactive Equatable {
	public static func == (
		lhs: CLLocationCoordinate2D,
		rhs: CLLocationCoordinate2D
	) -> Bool {
		lhs.longitude == rhs.longitude &&
		lhs.latitude  == rhs.latitude
	}
}

// MARK: Hashabale

extension CLLocationCoordinate2D: @retroactive Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(latitude)
		hasher.combine(longitude)
	}
}

// MARK: Description

extension CLLocationCoordinate2D: @retroactive CustomStringConvertible {
	fileprivate static let format: FloatingPointFormatStyle<CLLocationDegrees> = .number.precision(.fractionLength(...6))
	
	public var description: String {
		"(\(latitude.formatted(Self.format)), \(longitude.formatted(Self.format)))"
	}
}
