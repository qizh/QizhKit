//
//  Device+extra.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 16.09.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation
import DeviceKit

extension Device {
	public static var allDevicesWithDynamicIsland: [Device] {
		[
			.iPhone14Pro,
			.iPhone14ProMax,
			.iPhone15,
			.iPhone15Plus,
			.iPhone15Pro,
			.iPhone15ProMax,
		]
	}
	
	public var hasDynamicIsland: Bool {
			isOneOf(Device.allDevicesWithDynamicIsland)
		|| 	isOneOf(Device.allDevicesWithDynamicIsland.map(Device.simulator))
	}
}
