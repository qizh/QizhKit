//
//  Sequence+try-lossy.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 07.02.23.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Sequence {
	/// Unlike `compactMap` this method wont `rethrow`.
	/// It skips `transform` that throwed.
	@inlinable
	public func tryLossyCompactMap <Transformed> (
		_ transform: (Element) throws -> Transformed?
	) -> [Transformed] {
		compactMap { element in
			do {
				return try transform(element)
			} catch {
				return .none
			}
		}
	}
}
