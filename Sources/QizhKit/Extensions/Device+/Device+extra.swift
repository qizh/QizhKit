//
//  Device+extra.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 16.09.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

/// Already implemented in `DeviceKit`
/*
import Foundation
import DeviceKit

extension Device {
	public static var allDevicesWithDynamicIsland: [Device] {
		#if os(iOS)
		[
			.iPhone14Pro,
			.iPhone14ProMax,
			.iPhone15,
			.iPhone15Plus,
			.iPhone15Pro,
			.iPhone15ProMax,
		]
		#elseif os(visionOS)
		.empty
		#endif
	}
	
	public var hasDynamicIsland: Bool {
			isOneOf(Device.allDevicesWithDynamicIsland)
		|| 	isOneOf(Device.allDevicesWithDynamicIsland.map(Device.simulator))
	}
}
*/
