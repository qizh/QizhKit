//
//  EdgeInsets+common.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 25.06.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension EdgeInsets {
	static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
	@inlinable var isZero: Bool { self == .zero }
	@inlinable var isNotZero: Bool { self != .zero }
}

public extension Optional where Wrapped == EdgeInsets {
	var top:      CGFloat { self?.top      ?? .zero }
	var leading:  CGFloat { self?.leading  ?? .zero }
	var bottom:   CGFloat { self?.bottom   ?? .zero }
	var trailing: CGFloat { self?.trailing ?? .zero }
}

/*
extension EdgeInsets: WithUnknown {
	public static let unknown = EdgeInsets(
		top: .zero,
		leading: .greatestFiniteMagnitude,
		bottom: .greatestFiniteMagnitude,
		trailing: .zero
	)
}
*/
