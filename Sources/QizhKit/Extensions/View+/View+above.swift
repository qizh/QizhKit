//
//  View+above.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 06.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct InStackModifier<AddContent: View>: ViewModifier {
	private var order: Order
	private var alignment: Alignment
	private var spacing: CGFloat?
	private var size: CGFloat?
	private var addContent: AddContent
	
	public init(
		_ order: Order = .below,
		alignment: Alignment = .topLeading,
		spacing: CGFloat? = 0,
		size: CGFloat? = nil,
		@ViewBuilder content: () -> AddContent
	) {
		self.order = order
		self.alignment = alignment
		self.spacing = spacing
		self.size = size
		self.addContent = content()
	}
	
	@ViewBuilder public func body(content: Content) -> some View {
		if order.is(.above) {
			VStack(alignment: alignment.horizontal, spacing: spacing) {
				addContent
					.frame(height: size)
				content
			}
		} else if order.is(.below) {
			VStack(alignment: alignment.horizontal, spacing: spacing) {
				content
				addContent
					.frame(height: size)
			}
		} else if order.is(.leading) {
			HStack(alignment: alignment.vertical, spacing: spacing) {
				addContent
					.frame(width: size)
				content
			}
		} else if order.is(.trailing) {
			HStack(alignment: alignment.vertical, spacing: spacing) {
				content
				addContent
					.frame(width: size)
			}
		}
	}
	
	public enum Order: CaseComparable {
		case above, below, leading, trailing
		
		@inlinable var isVertical: Bool {
			isOne(of: .above, .below)
		}
		@inlinable var isHorizontal: Bool {
			isOne(of: .leading, .trailing)
		}
	}
}

public extension View {
	@inlinable func add<AddContent: View>(
		_ order: InStackModifier<AddContent>.Order = .below,
		alignment: Alignment = .topLeading,
		spacing: CGFloat? = 0,
		size: CGFloat? = nil,
		@ViewBuilder content: () -> AddContent
	) -> some View {
		modifier(
			InStackModifier(
				order,
				alignment: alignment,
				spacing: spacing,
				size: size,
				content: content
			)
		)
	}
	
	@inlinable func add0<AddContent: View>(
		_ order: InStackModifier<AddContent>.Order = .below,
		alignment: Alignment = .topLeading,
		@ViewBuilder content: () -> AddContent
	) -> some View {
		modifier(
			InStackModifier(
				order,
				alignment: alignment,
				spacing: 0,
				size: 0,
				content: content
			)
		)
	}
}
