//
//  CLLocationCoordinate2D+.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 09.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
	public init?(latitude: String, longitude: String) {
		guard
			let lat = CLLocationDegrees(latitude),
			let lon = CLLocationDegrees(longitude)
		else { return nil }
		
		self.init(
			 latitude: lat.truncatingRemainder(dividingBy: 90),
			longitude: lon.truncatingRemainder(dividingBy: 180)
		)
	}
	
	public init?(latitude: String?, longitude: String?) {
		guard
			let latitude = latitude,
			let longitude = longitude,
			let lat = CLLocationDegrees(latitude),
			let lon = CLLocationDegrees(longitude)
		else { return nil }
		
		self.init(
			 latitude: lat.truncatingRemainder(dividingBy: 90),
			longitude: lon.truncatingRemainder(dividingBy: 180)
		)
	}
}

extension CLLocation {
	convenience public init(coordinate: CLLocationCoordinate2D) {
		self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
	}
}

extension CLLocationCoordinate2D {
	@inlinable public static var zero: CLLocationCoordinate2D {
		CLLocationCoordinate2D(latitude: .zero, longitude: .zero)
	}
	
	@inlinable public var isNotZero: Bool {
		not(isZero)
	}
	
	public var isZero: Bool {
		latitude.isZero && longitude.isZero
		|| latitude.truncatingRemainder(dividingBy: 90).isZero
		&& longitude.truncatingRemainder(dividingBy: 180).isZero
	}
	
	public var nonZero: CLLocationCoordinate2D? {
		if isZero {
			.none
		} else {
			self
		}
	}
}
