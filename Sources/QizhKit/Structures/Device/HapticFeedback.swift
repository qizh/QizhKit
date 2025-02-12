//
//  HapticFeedback.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 13.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension View {
	@available(iOS, introduced: 13.0, deprecated: 17.0, renamed: "sensoryFeedback", message: "sensoryFeedback is available on iOS 17")
	public func hapticFeedback(_ action: HapticAction) -> some View {
		simultaneousGesture(TapGesture().onEnded { action.produceHapticFeedback() })
	}
	
	internal func debugWithRandomHapticFeedback() -> some View {
		simultaneousGesture(TapGesture().onEnded { HapticAction.randomAction.produceHapticFeedback() })
	}
}

public enum HapticAction: CaseIterable, Sendable, CaseComparable, DefaultCaseFirst {
	case none
	case random
	
	case select
	
	case lightImpact
	case mediumImpact
	case heavyImpact
	case softImpact
	case rigidImpact
	
	case errorNotification
	case successNotification
	case warningNotification
	
	@MainActor public func produceHapticFeedback() {
		#if os(iOS)
		switch self {
		case .none: break
		case .random: HapticAction.randomAction.produceHapticFeedback()
		case .select: 		UISelectionFeedbackGenerator().selectionChanged()
		case .lightImpact: 	UIImpactFeedbackGenerator(style: .light).impactOccurred()
		case .mediumImpact: UIImpactFeedbackGenerator(style: .medium).impactOccurred()
		case .heavyImpact: 	UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
		case .softImpact: 	UIImpactFeedbackGenerator(style: .soft).impactOccurred()
		case .rigidImpact: 	UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
		case .errorNotification: 	UINotificationFeedbackGenerator().notificationOccurred(.error)
		case .successNotification: 	UINotificationFeedbackGenerator().notificationOccurred(.success)
		case .warningNotification: 	UINotificationFeedbackGenerator().notificationOccurred(.warning)
		}
		#elseif os(visionOS)
		/// No haptic
		#endif
	}
	
	@inlinable @MainActor public static func produceHapticFeedback(_ action: HapticAction) {
		action.produceHapticFeedback()
	}
	
	@inlinable public static var randomAction: Self {
		Self.allCasesButDefault
			.randomElement()
			.forceUnwrap(because: "Cases are defined and not empty")
	}
	
	@inlinable public var isDefault: Bool { isOne(of: .none, .random) }
	public static let allCasesButDefault: [Self] = [
		.select,
		
		.lightImpact,
		.mediumImpact,
		.heavyImpact,
		.softImpact,
		.rigidImpact,
		
		.errorNotification,
		.successNotification,
		.warningNotification,
	]
	
	public static let allCases: [Self] = [
		.none,
		.random,
		
		.select,
		
		.lightImpact,
		.mediumImpact,
		.heavyImpact,
		.softImpact,
		.rigidImpact,
		
		.errorNotification,
		.successNotification,
		.warningNotification,
	]
}
