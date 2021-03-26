//
//  RoundedBorderViewModifier.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 21.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension View {
	@inlinable func round(
		_ radius: CGFloat,
		_ corners: UIRectCorner = .allCorners,
		border color: Color,
		weight: CGFloat = .one,
		position: LinePosition = .center,
		tap define: Bool = false
	) -> some View {
		clipShape(RoundedCornersRectangle(radius, corners))
		.overlay(
			RoundedCornersRectangle(radius, corners)
				.inset(by: position.inset(for: weight))
				.stroke(color, lineWidth: weight)
		)
		.apply(when: define) {
			$0.contentShape(RoundedCornersRectangle(radius, corners))
		}
	}
	
	@inlinable func round(
		_ radius: CGFloat,
		_ corners: UIRectCorner = .allCorners
	) -> some View {
		clipShape(RoundedCornersRectangle(radius, corners), style: FillStyle(eoFill: true, antialiased: true))
	}
}

public enum LinePosition: EasyCaseComparable {
	case center
	case inner
	case outer
	
	public func inset(for weight: CGFloat) -> CGFloat {
		switch self {
		case .center: return .zero
		case .inner:  return  weight.half
		case .outer:  return -weight.half
		}
	}
}

public extension View {
	@inlinable func circle(
		border color: Color,
		weight: CGFloat = .one,
		position: LinePosition = .center
	) -> some View {
		self.clipShape(Circle())
			.overlay(
				Circle()
					.inset(by: position.inset(for: weight))
					.stroke(color, lineWidth: weight)
			)
	}
	
	@inlinable func circle(
		weight: CGFloat = .one,
		position: LinePosition = .center
	) -> some View {
		self.clipShape(Circle())
			.overlay(
				Circle()
					.inset(by: position.inset(for: weight))
					.stroke(lineWidth: weight)
			)
	}
}

public extension View {
	@inlinable func corner(
		radius: CGFloat,
		tap define: Bool = false
	) -> some View {
		clipShape(RoundedRectangle(radius))
		.apply(when: define) { v in v
			.contentShape(RoundedRectangle(radius))
		}
	}
	
	@inlinable func roundedBorder(
		_ color: Color,
		radius: CGFloat,
		weight: CGFloat = 1,
		tap define: Bool = false
	) -> some View {
		clipShape(RoundedRectangle(radius))
		.overlay(RoundedRectangle(radius).strokeBorder(color, lineWidth: weight))
		.apply(when: define) { v in v
			.contentShape(RoundedRectangle(radius))
		}
	}
	
	@inlinable func roundButton(
		_ radius: CGFloat,
		_ corners: UIRectCorner = .allCorners,
		border color: Color,
		weight: CGFloat = .one
	) -> some View {
		clipShape(RoundedCornersRectangle(radius, corners))
			.overlay(RoundedCornersRectangle(radius, corners).stroke(color, lineWidth: weight))
			.contentShape(RoundedCornersRectangle(radius, corners))
	}
	
	@inlinable func roundButton(
		_ radius: CGFloat,
		_ corners: UIRectCorner = .allCorners
	) -> some View {
		clipShape(RoundedCornersRectangle(radius, corners))
			.contentShape(RoundedCornersRectangle(radius, corners))
	}
	
	@inlinable func circleBorder<S: ShapeStyle>(
		_ content: S,
		lineWidth: CGFloat = 1,
		tap define: Bool = false
	) -> some View {
		clipShape(Circle())
		.overlay(Circle().strokeBorder(content, lineWidth: lineWidth))
		.apply(when: define) { v in v
			.contentShape(Circle())
		}
	}
	
	@inlinable func circleBorder(
		_ color: Color,
		size: CGFloat = 1,
		tap define: Bool = false
	) -> some View {
		 clipShape(Circle())
		.overlay(Circle().strokeBorder(color, lineWidth: size))
		.apply(when: define) { v in v
			.contentShape(Circle())
		}
	}
}

public extension RoundedRectangle {
	@inlinable init(_ radius: CGFloat) {
		self.init(cornerRadius: radius, style: .continuous)
	}
}

#if DEBUG
struct RoundedBorderViewModifier_Previews: PreviewProvider {
    static var previews: some View {
		Group {
			Color.blue
				.frame(width: 100, height: 100)
				.roundedBorder(Color.pink, radius: 10, weight: 4)
			
			Color.white
				.frame(width: 100, height: 100)
				.roundedBorder(Color.black, radius: 10, weight: 1/3)
		}
		.clipped()
		.padding()
		.previewLayout(.sizeThatFits)
    }
}
#endif
