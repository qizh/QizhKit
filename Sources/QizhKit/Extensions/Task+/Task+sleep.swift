//
//  Task+sleep.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.06.2024.
//  Copyright © 2024 Bespokely. All rights reserved.
//

import Foundation

fileprivate let nanosecondsInMilliseconds: UInt64 = 1_000_000
fileprivate let nanosecondsInSeconds: UInt64 = 1_000_000_000

extension Task where Success == Never, Failure == Never {
	/// Universal sleep method that's using different approaches for pre- and post-iOS 16
	/// On iOS 16 and higher is using `continuous` clock.
	public static func sleep(milliseconds: some BinaryInteger) async {
		if #available(iOS 16.0, *) {
			try? await sleep(until: .now + .milliseconds(milliseconds), clock: .continuous)
		} else {
			try? await sleep(nanoseconds: UInt64(milliseconds) * nanosecondsInMilliseconds)
		}
	}
	
	/// Universal sleep method that's using different approaches for pre- and post-iOS 16.
	/// On iOS 16 and higher is using `continuous` clock.
	public static func sleep(seconds: some BinaryInteger) async {
		if #available(iOS 16.0, *) {
			try? await sleep(until: .now + .seconds(seconds), clock: .continuous)
		} else {
			try? await sleep(nanoseconds: UInt64(seconds) * nanosecondsInSeconds)
		}
	}
}
