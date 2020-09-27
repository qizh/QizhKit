//
//  Optional+matching.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Optional {
	/// ```
	/// let activeFriend = database.userRecord(withID: id)
	///		.matching { $0.isFriend }
    ///		.matching(\.isActive)
	/// ```
    func matching(_ predicate: (Wrapped) -> Bool) -> Wrapped? {
        guard let defined = self else { return nil }
        guard predicate(defined) else { return nil }
        return defined
    }
}
