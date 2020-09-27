//
//  CLLocationCoordinate2D+.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 09.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation
import CoreLocation

public extension CLLocationCoordinate2D {
	init?(latitude: String, longitude: String) {
		guard
			let lat = CLLocationDegrees(latitude),
			let lon = CLLocationDegrees(longitude)
		else { return nil }
		
		self.init(latitude: lat, longitude: lon)
	}
	
	init?(latitude: String?, longitude: String?) {
		guard
			let latitude = latitude,
			let longitude = longitude,
			let lat = CLLocationDegrees(latitude),
			let lon = CLLocationDegrees(longitude)
		else { return nil }
		
		self.init(latitude: lat, longitude: lon)
	}
}

public extension CLLocation {
	convenience init(coordinate: CLLocationCoordinate2D) {
		self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
	}
}

public extension CLLocationCoordinate2D {
	@inlinable static var zero: CLLocationCoordinate2D { .init() }
	var isZero: Bool { latitude.isZero && longitude.isZero }
}
