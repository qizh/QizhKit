//
//  CLLocationCoordinate2D+Equatible.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 05.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Equatable {
	public static func == (
		lhs: CLLocationCoordinate2D,
		rhs: CLLocationCoordinate2D
	) -> Bool {
		lhs.longitude == rhs.longitude &&
		lhs.latitude  == rhs.latitude
	}
}

extension CLLocationCoordinate2D: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(latitude)
		hasher.combine(longitude)
	}
}
