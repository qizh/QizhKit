//
//  Data+voice.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.08.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Data {
	public func pcm16DurationSeconds(
		sampleRate: Double = 24000,
		channels: Int = 1,
		bytesPerSample: UInt8 = 2
	) -> TimeInterval {
		if sampleRate > 0, channels > 0, bytesPerSample > 0 {
			self.count.double / (sampleRate * channels.double * bytesPerSample.double)
		} else {
			0
		}
	}
}
