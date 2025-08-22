//
//  ProgressView.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 05.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct ProgressView: View {
	private let state: BasicBackendFetchState
	private let name: String?
	private let progress: FetchProgress
	private let error: FetchError?
	private let size: Size
	private let show: StatesSet
	private let color: ColorMode
	
	@State private var isPresentingError: Bool = false
	@State private var rotation: Angle = .zero
	
	@Environment(\.colorScheme) private var colorScheme: ColorScheme
	@Environment(\.secondaryColor) private var secondaryColor: Color
	
	// MARK: Init
	
	public init(
		name: String? = .none,
		state: BasicBackendFetchState,
		error: FetchError? = .none,
		size: Size = .visual,
		show: StatesSet = .all,
		color: ColorMode = .multi
	) {
		self.state = state
		self.name = name
		self.progress = .undetermined
		self.error = error
		self.size = size
		self.show = show
		self.color = color
	}
	
	public init(
		state: GeneralBackendFetchState,
		size: Size = .visual,
		show: StatesSet = .all,
		color: ColorMode = .multi
	) {
		self.state = state.asBasic
		self.name = state.fetcherName
		self.progress = state.progress ?? .none
		self.error = state.error
		self.size = size
		self.show = show
		self.color = color
	}
	
	public init(
		state: GeneralBackendFetchState,
		_ size: Size = .visual,
		_ show: StatesSet = .all,
		_ color: ColorMode = .multi
	) {
		self.state = state.asBasic
		self.name = state.fetcherName
		self.progress = state.progress ?? .none
		self.error = state.error
		self.size = size
		self.show = show
		self.color = color
	}
	
	@inlinable public init(
		states: [GeneralBackendFetchState],
		size: Size = .visual,
		show: StatesSet = .all,
		color: ColorMode = .multi
	) {
		assert(
			states.isNotEmpty,
			"States should contain at least one element"
		)
		let state = states.sorted(by: \.importance)
			.last.forceUnwrapBecauseTested()
		self.init(state: state, size, show, color)
	}
	
	public init(
		progress: FetchProgress,
		size: Size = .visual,
		show: StatesSet = .all,
		color: ColorMode = .multi
	) {
		self.state = .init(progress)
		self.name = nil
		self.progress = progress.normalized
		self.error = nil
		self.size = size
		self.show = show
		self.color = color
	}
	
	@inlinable
	public init(
		_ progress: FetchProgress,
		_ size: Size = .visual,
		_ show: StatesSet = .all,
		_ color: ColorMode = .multi
	) {
		self.init(
			progress: progress,
			size: size,
			show: show,
			color: color
		)
	}
	
	@inlinable public init(
		_ progress: FetchProgress,
		_ size: Size = .visual,
		_ color: ColorMode = .multi
	) {
		self.init(progress, size, .all, color)
	}
	
	@inlinable public init(
		progress: FetchProgress
	) {
		self.init(progress, .visual)
	}
	
	@inlinable public init(
		_ progress: FetchProgress
	) {
		self.init(progress, .visual)
	}
	
	@inlinable public init(
		_ value: Double,
		_ size: Size = .visual,
		_ show: StatesSet = .all,
		_ color: ColorMode = .multi
	) {
		self.init(FetchProgress(value), size, show, color)
	}
	
	@inlinable public init(
		_ value: Double,
		_ size: Size = .visual,
		_ color: ColorMode = .multi
	) {
		self.init(FetchProgress(value), size, .all, color)
	}
	
	public static func sized(
		_ size: Size,
		color: ColorMode = .multi
	) -> (FetchProgress) -> ProgressView {
		{ progress in ProgressView(progress, size, color) }
	}
	
	public static func visual(
		_ progress: FetchProgress
	) -> ProgressView {
		ProgressView(progress, .visual)
	}
	
	// MARK: UI
	
	public var body: some View {
		content
			.square(size.value)
	}
	
	@ViewBuilder private var content: some View {
		ZStack {
//			state.labeledView(label: "state")
			if state.is(.inProgress) {
				if progress.isUndetermined {
					undeterminedProgressView()
						.transition(transition)
				}
				
				if !progress.isUndetermined {
					determinedProgressView(for: progress)
						.transition(transition)
				}
			}
			
			if state.is(.failure) && show.showErrorState {
				failureView()
					.transition(transition)
			}
			
			if state.is(.success) {
				if show.showCompleteState {
					completeView()
						.transition(transition)
				}
				
				if !show.showCompleteState {
					determinedProgressView(for: .complete)
						.transition(transition)
				}
			}
		}
	}
	
	// MARK: Colors
	
	public static let red: Color =
		.init(
			.displayP3,
			red: 0.949,
			green: 0.353,
			blue: 0.325,
			opacity: 1
		)
	
	public static let yellow: Color =
		.init(
			.displayP3,
			red: 0.859,
			green: 0.678,
			blue: 0.039,
			opacity: 1
		)
	
	public static let blue: Color =
		.init(
			.displayP3,
			red: 0.0,
			green: 0.345,
			blue: 0.875,
			opacity: 1
		)
	
	public static let green: Color =
		.init(
			.displayP3,
			red: 0.298,
			green: 0.706,
			blue: 0.298,
			opacity: 1
		)
	
	public static let multiGradient: Gradient =
		Gradient(colors: [
			red,
			yellow,
			green,
			blue,
			red,
		])
	
	/*
	public static var monoGradient: Gradient =
		Gradient(colors: [
			.accentColor,
			.accentColor(0.2),
			.accentColor,
		])
	*/
	
	public static func monoGradient(color: Color) -> Gradient {
		Gradient(
			colors: [
				color,
				color.opacity(0.2),
				color,
			]
		)
	}
	
	public var undeterminedGradient: Gradient {
		switch color {
		case .multi: 			Self.multiGradient
		case .mono(let color): 	Self.monoGradient(color: color)
		}
	}
	
	private var determinedGradient: Gradient {
		color.is(.multi)
			? Self.multiGradient
			: Gradient(colors: [.accentColor])
	}
	
	private let transition = AnyTransition.blur(radius: 4).combined(with: .opacity)
	
	// MARK: Main Views
	
	private func determinedProgressView(for progress: FetchProgress) -> some View {
		ZStack(alignment: .center) {
			Circle()
				.stroke(secondaryColor, lineWidth: size.contourLineWidth)
			
			Circle()
				.trim(from: .zero, to: progress.cgvalue)
				.stroke(style: .init(lineWidth: size.progressLineWidth, lineCap: .round))
				.fill(
					AngularGradient(
						gradient: determinedGradient,
						center: .center,
						angle: .degrees(150)
					)
				)
				.rotationEffect(rotation)
				.animateForever(
					assigning: rotation.circle,
					to: $rotation,
					using: .linear(duration: 1)
				)
		}
	}
	
	private func undeterminedProgressView() -> some View {
		Circle()
			.stroke(
				style: .init(
					lineWidth: size.progressLineWidth,
					lineCap: .round,
					dash: size.dashes
				)
			)
			.fill(
				AngularGradient(
					gradient: undeterminedGradient,
					center: .center,
					startAngle: rotation * -2,
					endAngle: .degrees(360) - rotation * 2
				)
			)
			.rotationEffect(rotation)
			/*
			.animateForever(using: .linear(duration: 3)) {
				self.rotation = self.rotation.circle
			}
			*/
			.animateForever(
				assigning: rotation.circle,
				to: $rotation,
				using: .linear(duration: 3)
			)
	}
	
	private func failureView() -> some View {
		Exclamationmark(size)
			.fill(
				AngularGradient(
					gradient: Gradient(colors: [Self.red, Self.yellow, Self.red]),
					center: .center,
					startAngle: rotation * -2,
					endAngle: .degrees(360) - rotation * 2
				)
			)
			.animateForever(
				assigning: rotation.circle,
				to: $rotation,
				using: .linear(duration: 3)
			)
			.aspectRatio([100, 91], contentMode: .fill)
//			.square(size.value * 1.1, .top)
//			.offset(x: 0, y: size.value / 60)
			.button(assigning: true, to: $isPresentingError)
			.alert(isPresented: $isPresentingError) {
				Alert(
					title: Text(name.map { $0 + .space }.orEmpty + "Error"),
					message: error.map(\.localizedDescription).mapText(),
					dismissButton: .cancel()
				)
			}
		
		/*
		AngularGradient(
			gradient: Gradient(colors: [red, yellow, red]),
			center: .center,
			angle: .degrees(150) + rotation
		)
		.mask(
			Image(systemName: "exclamationmark.triangle")
				.resizable()
				.scaledToFit()
				.font(size.failureFont)
		)
		.square(size.value * 1.1, .top)
		.offset(x: 0, y: size.value / 60)
		.animateForever(
			assigning: rotation + Angle(degrees: 360),
			to: \.rotation, on: self,
			using: .linear(duration: 4)
		)
		.button(assigning: true, to: \.isPresentingError, on: self)
		.alert(isPresented: $isPresentingError) {
			Alert(
				title: Text(name.map { $0 + .space }.orEmpty + "Error"),
				message: error.map(\.localizedDescription).mapText(),
				dismissButton: .cancel()
			)
		}
		*/
	}
	
	private func completeView() -> some View {
		Checkmark(size)
			.fill(
				AngularGradient(
					gradient: Gradient(colors: [Self.blue, Self.green, Self.blue]),
					center: .center,
					startAngle: rotation * -2,
					endAngle: .degrees(360) - rotation * 2
				)
			)
			.animateForever(
				assigning: rotation.circle,
				to: $rotation,
				using: .linear(duration: 3)
			)
			.square(size.value * 1.04, .center)
		
		/*
		AngularGradient(
			gradient: Gradient(colors: [blue, green, blue]),
			center: .center,
			angle: .degrees(150) + rotation
		)
		.mask(
			Image(systemName: "checkmark.circle")
				.resizable()
				.scaledToFit()
				.font(size.failureFont)
		)
		.square(size.value * 1.04, .center)
		.animateForever(
			assigning: rotation + Angle(degrees: 360),
			to: \.rotation, on: self,
			using: .linear(duration: 4)
		)
		*/
	}
	
	// MARK: Size
	
	public enum Size: CaseIterable,
					  EasyCaseComparable,
					  Identifiable,
					  Hashable,
					  Sendable {
		case small
		case visual
		case large
		
		@inlinable
		public var id: Int8 {
			switch self {
			case .small: 	return 1
			case .visual: 	return 2
			case .large: 	return 3
			}
		}
		
		public var value: CGFloat {
			switch self {
			case .small: 	return 18
			case .visual: 	return 32
			case .large: 	return 64
			}
		}
		
		var contourLineWidth: CGFloat {
			switch self {
			case .small: 	return 1/3
			case .visual: 	return 1/2
			case .large: 	return 1
			}
		}
		
		var progressLineWidth: CGFloat {
			switch self {
			case .small: 	return 1.2
			case .visual: 	return 1.8
			case .large: 	return 2.5
			}
		}
		
		var dashes: [CGFloat] {
			switch self {
			case .small: 	return [3, 4]
			case .visual: 	return [4, 6]
			case .large: 	return [6, 7.5]
			}
		}
		
		var failureFont: Font {
			switch self {
			case .small: 	return .light(42)
			case .visual: 	return .thin(42)
			case .large: 	return .ultraLight(42)
			}
		}
	}
	
	// MARK: States Set
	
	public enum StatesSet {
		case all
		case progress
		
		var showCompleteState: Bool {
			switch self {
			case .all: return true
			case .progress: return false
			}
		}
		
		var showErrorState: Bool {
			switch self {
			case .all: return true
			case .progress: return false
			}
		}
	}
	
	public enum ColorMode: Hashable, Sendable, EasyCaseComparable {
		case multi
		case mono(_ color: Color)
		
		public var id: Color {
			switch self {
			case .multi: 		  .clear
			case .mono(let color): color
			}
		}
		
		@available(*, deprecated, renamed: "mono(_:)", message: "You should provide color explicitly")
		internal static var mono: ColorMode {
			.mono(.accentColor)
		}
	}
	
	// MARK: Icons
	
	public struct Exclamationmark: Shape {
		private let size: Size
		public init(_ size: Size) {
			self.size = size
		}
		
		public func path(in rect: CGRect) -> Path{
			var path = Path()
			let width = rect.size.width
			let height = rect.size.height
			
			switch size {
			case .small:
				path.move(to: CGPoint(x: 0.13131*width, y: 0.9946*height))
				path.addLine(to: CGPoint(x: 0.85951*width, y: 0.9946*height))
				path.addCurve(to: CGPoint(x: 0.98111*width, y: 0.85757*height),control1: CGPoint(x: 0.93322*width, y: 0.9946*height),control2: CGPoint(x: 0.98111*width, y: 0.93265*height))
				path.addCurve(to: CGPoint(x: 0.96467*width, y: 0.79036*height),control1: CGPoint(x: 0.98111*width, y: 0.83552*height),control2: CGPoint(x: 0.97594*width, y: 0.81189*height))
				path.addLine(to: CGPoint(x: 0.59987*width, y: 0.07632*height))
				path.addCurve(to: CGPoint(x: 0.49517*width, y: 0.00754*height),control1: CGPoint(x: 0.57687*width, y: 0.03117*height),control2: CGPoint(x: 0.53649*width, y: 0.00754*height))
				path.addCurve(to: CGPoint(x: 0.39048*width, y: 0.07632*height),control1: CGPoint(x: 0.45433*width, y: 0.00754*height),control2: CGPoint(x: 0.41301*width, y: 0.03117*height))
				path.addLine(to: CGPoint(x: 0.0252*width, y: 0.79141*height))
				path.addCurve(to: CGPoint(x: 0.00924*width, y: 0.85757*height),control1: CGPoint(x: 0.0144*width, y: 0.81242*height),control2: CGPoint(x: 0.00924*width, y: 0.83552*height))
				path.addCurve(to: CGPoint(x: 0.13131*width, y: 0.9946*height),control1: CGPoint(x: 0.00924*width, y: 0.93265*height),control2: CGPoint(x: 0.05713*width, y: 0.9946*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.13178*width, y: 0.93055*height))
				path.addCurve(to: CGPoint(x: 0.0684*width, y: 0.85757*height),control1: CGPoint(x: 0.09375*width, y: 0.93055*height),control2: CGPoint(x: 0.0684*width, y: 0.8959*height))
				path.addCurve(to: CGPoint(x: 0.07544*width, y: 0.82134*height),control1: CGPoint(x: 0.0684*width, y: 0.84707*height),control2: CGPoint(x: 0.06981*width, y: 0.83447*height))
				path.addLine(to: CGPoint(x: 0.44024*width, y: 0.10677*height))
				path.addCurve(to: CGPoint(x: 0.49517*width, y: 0.07212*height),control1: CGPoint(x: 0.45198*width, y: 0.08314*height),control2: CGPoint(x: 0.47358*width, y: 0.07212*height))
				path.addCurve(to: CGPoint(x: 0.5501*width, y: 0.10677*height),control1: CGPoint(x: 0.51677*width, y: 0.07212*height),control2: CGPoint(x: 0.5379*width, y: 0.08314*height))
				path.addLine(to: CGPoint(x: 0.91397*width, y: 0.82187*height))
				path.addCurve(to: CGPoint(x: 0.92242*width, y: 0.85757*height),control1: CGPoint(x: 0.91961*width, y: 0.83342*height),control2: CGPoint(x: 0.92242*width, y: 0.84654*height))
				path.addCurve(to: CGPoint(x: 0.85857*width, y: 0.93055*height),control1: CGPoint(x: 0.92242*width, y: 0.8959*height),control2: CGPoint(x: 0.89613*width, y: 0.93055*height))
				path.addLine(to: CGPoint(x: 0.13178*width, y: 0.93055*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.49517*width, y: 0.64493*height))
				path.addCurve(to: CGPoint(x: 0.52381*width, y: 0.6108*height),control1: CGPoint(x: 0.51301*width, y: 0.64493*height),control2: CGPoint(x: 0.52381*width, y: 0.63285*height))
				path.addLine(to: CGPoint(x: 0.52945*width, y: 0.32991*height))
				path.addCurve(to: CGPoint(x: 0.49517*width, y: 0.29211*height),control1: CGPoint(x: 0.52992*width, y: 0.30838*height),control2: CGPoint(x: 0.51489*width, y: 0.29211*height))
				path.addCurve(to: CGPoint(x: 0.4609*width, y: 0.32991*height),control1: CGPoint(x: 0.47452*width, y: 0.29211*height),control2: CGPoint(x: 0.46043*width, y: 0.30786*height))
				path.addLine(to: CGPoint(x: 0.46606*width, y: 0.6108*height))
				path.addCurve(to: CGPoint(x: 0.49517*width, y: 0.64493*height),control1: CGPoint(x: 0.46653*width, y: 0.63233*height),control2: CGPoint(x: 0.47686*width, y: 0.64493*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.49517*width, y: 0.80769*height))
				path.addCurve(to: CGPoint(x: 0.53884*width, y: 0.76044*height),control1: CGPoint(x: 0.51865*width, y: 0.80769*height),control2: CGPoint(x: 0.53884*width, y: 0.78616*height))
				path.addCurve(to: CGPoint(x: 0.49517*width, y: 0.71266*height),control1: CGPoint(x: 0.53884*width, y: 0.73366*height),control2: CGPoint(x: 0.51912*width, y: 0.71266*height))
				path.addCurve(to: CGPoint(x: 0.45151*width, y: 0.76044*height),control1: CGPoint(x: 0.47123*width, y: 0.71266*height),control2: CGPoint(x: 0.45151*width, y: 0.73419*height))
				path.addCurve(to: CGPoint(x: 0.49517*width, y: 0.80769*height),control1: CGPoint(x: 0.45151*width, y: 0.78616*height),control2: CGPoint(x: 0.4717*width, y: 0.80769*height))
				path.closeSubpath()
			case .visual:
				path.move(to: CGPoint(x: 0.12335*width, y: 0.99903*height))
				path.addLine(to: CGPoint(x: 0.87349*width, y: 0.99903*height))
				path.addCurve(to: CGPoint(x: 0.98694*width, y: 0.87133*height),control1: CGPoint(x: 0.94098*width, y: 0.99903*height),control2: CGPoint(x: 0.98694*width, y: 0.93894*height))
				path.addCurve(to: CGPoint(x: 0.97162*width, y: 0.80801*height),control1: CGPoint(x: 0.98694*width, y: 0.84987*height),control2: CGPoint(x: 0.98264*width, y: 0.8284*height))
				path.addLine(to: CGPoint(x: 0.59584*width, y: 0.06486*height))
				path.addCurve(to: CGPoint(x: 0.49818*width, y: 0.00101*height),control1: CGPoint(x: 0.57477*width, y: 0.02301*height),control2: CGPoint(x: 0.53648*width, y: 0.00101*height))
				path.addCurve(to: CGPoint(x: 0.40005*width, y: 0.06486*height),control1: CGPoint(x: 0.46036*width, y: 0.00101*height),control2: CGPoint(x: 0.42111*width, y: 0.02301*height))
				path.addLine(to: CGPoint(x: 0.02378*width, y: 0.80909*height))
				path.addCurve(to: CGPoint(x: 0.00942*width, y: 0.87133*height),control1: CGPoint(x: 0.01421*width, y: 0.8284*height),control2: CGPoint(x: 0.00942*width, y: 0.84987*height))
				path.addCurve(to: CGPoint(x: 0.12335*width, y: 0.99903*height),control1: CGPoint(x: 0.00942*width, y: 0.93894*height),control2: CGPoint(x: 0.05586*width, y: 0.99903*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.12383*width, y: 0.95933*height))
				path.addCurve(to: CGPoint(x: 0.04628*width, y: 0.87133*height),control1: CGPoint(x: 0.07788*width, y: 0.95933*height),control2: CGPoint(x: 0.04628*width, y: 0.91748*height))
				path.addCurve(to: CGPoint(x: 0.05538*width, y: 0.82679*height),control1: CGPoint(x: 0.04628*width, y: 0.85792*height),control2: CGPoint(x: 0.04867*width, y: 0.84289*height))
				path.addLine(to: CGPoint(x: 0.43116*width, y: 0.08418*height))
				path.addCurve(to: CGPoint(x: 0.49818*width, y: 0.04125*height),control1: CGPoint(x: 0.44552*width, y: 0.0552*height),control2: CGPoint(x: 0.47185*width, y: 0.04125*height))
				path.addCurve(to: CGPoint(x: 0.56472*width, y: 0.08418*height),control1: CGPoint(x: 0.52499*width, y: 0.04125*height),control2: CGPoint(x: 0.54988*width, y: 0.05467*height))
				path.addLine(to: CGPoint(x: 0.93955*width, y: 0.82679*height))
				path.addCurve(to: CGPoint(x: 0.95008*width, y: 0.87133*height),control1: CGPoint(x: 0.94673*width, y: 0.84128*height),control2: CGPoint(x: 0.95008*width, y: 0.85738*height))
				path.addCurve(to: CGPoint(x: 0.87301*width, y: 0.95933*height),control1: CGPoint(x: 0.95008*width, y: 0.91748*height),control2: CGPoint(x: 0.91849*width, y: 0.95933*height))
				path.addLine(to: CGPoint(x: 0.12383*width, y: 0.95933*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.49818*width, y: 0.64865*height))
				path.addCurve(to: CGPoint(x: 0.51781*width, y: 0.62343*height),control1: CGPoint(x: 0.50967*width, y: 0.64865*height),control2: CGPoint(x: 0.51733*width, y: 0.63899*height))
				path.addLine(to: CGPoint(x: 0.52164*width, y: 0.33154*height))
				path.addCurve(to: CGPoint(x: 0.49818*width, y: 0.30525*height),control1: CGPoint(x: 0.52164*width, y: 0.31598*height),control2: CGPoint(x: 0.51206*width, y: 0.30525*height))
				path.addCurve(to: CGPoint(x: 0.4752*width, y: 0.33154*height),control1: CGPoint(x: 0.4843*width, y: 0.30525*height),control2: CGPoint(x: 0.47472*width, y: 0.31598*height))
				path.addLine(to: CGPoint(x: 0.47903*width, y: 0.62343*height))
				path.addCurve(to: CGPoint(x: 0.49818*width, y: 0.64865*height),control1: CGPoint(x: 0.47903*width, y: 0.63846*height),control2: CGPoint(x: 0.48669*width, y: 0.64865*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.49818*width, y: 0.80426*height))
				path.addCurve(to: CGPoint(x: 0.53313*width, y: 0.76509*height),control1: CGPoint(x: 0.51781*width, y: 0.80426*height),control2: CGPoint(x: 0.53313*width, y: 0.78601*height))
				path.addCurve(to: CGPoint(x: 0.49818*width, y: 0.72645*height),control1: CGPoint(x: 0.53313*width, y: 0.74416*height),control2: CGPoint(x: 0.51781*width, y: 0.72645*height))
				path.addCurve(to: CGPoint(x: 0.46324*width, y: 0.76509*height),control1: CGPoint(x: 0.47903*width, y: 0.72645*height),control2: CGPoint(x: 0.46324*width, y: 0.74416*height))
				path.addCurve(to: CGPoint(x: 0.49818*width, y: 0.80426*height),control1: CGPoint(x: 0.46324*width, y: 0.78601*height),control2: CGPoint(x: 0.47903*width, y: 0.80426*height))
				path.closeSubpath()
			case .large:
				path.move(to: CGPoint(x: 0.11996*width, y: 0.99635*height))
				path.addLine(to: CGPoint(x: 0.88949*width, y: 0.99635*height))
				path.addCurve(to: CGPoint(x: 0.99936*width, y: 0.87401*height),control1: CGPoint(x: 0.95395*width, y: 0.99635*height),control2: CGPoint(x: 0.99936*width, y: 0.93733*height))
				path.addCurve(to: CGPoint(x: 0.9852*width, y: 0.81338*height),control1: CGPoint(x: 0.99936*width, y: 0.85362*height),control2: CGPoint(x: 0.99545*width, y: 0.83323*height))
				path.addLine(to: CGPoint(x: 0.59994*width, y: 0.06432*height))
				path.addCurve(to: CGPoint(x: 0.50473*width, y: 0.00369*height),control1: CGPoint(x: 0.57943*width, y: 0.02408*height),control2: CGPoint(x: 0.54184*width, y: 0.00369*height))
				path.addCurve(to: CGPoint(x: 0.40902*width, y: 0.06432*height),control1: CGPoint(x: 0.46811*width, y: 0.00369*height),control2: CGPoint(x: 0.42953*width, y: 0.02408*height))
				path.addLine(to: CGPoint(x: 0.02328*width, y: 0.81499*height))
				path.addCurve(to: CGPoint(x: 0.00961*width, y: 0.87401*height),control1: CGPoint(x: 0.014*width, y: 0.83323*height),control2: CGPoint(x: 0.00961*width, y: 0.85362*height))
				path.addCurve(to: CGPoint(x: 0.11996*width, y: 0.99635*height),control1: CGPoint(x: 0.00961*width, y: 0.93733*height),control2: CGPoint(x: 0.05551*width, y: 0.99635*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.12094*width, y: 0.96899*height))
				path.addCurve(to: CGPoint(x: 0.03549*width, y: 0.87401*height),control1: CGPoint(x: 0.07016*width, y: 0.96899*height),control2: CGPoint(x: 0.03549*width, y: 0.92445*height))
				path.addCurve(to: CGPoint(x: 0.04525*width, y: 0.82572*height),control1: CGPoint(x: 0.03549*width, y: 0.85953*height),control2: CGPoint(x: 0.03793*width, y: 0.84396*height))
				path.addLine(to: CGPoint(x: 0.431*width, y: 0.07667*height))
				path.addCurve(to: CGPoint(x: 0.50473*width, y: 0.03052*height),control1: CGPoint(x: 0.44662*width, y: 0.04554*height),control2: CGPoint(x: 0.47543*width, y: 0.03052*height))
				path.addCurve(to: CGPoint(x: 0.57797*width, y: 0.07667*height),control1: CGPoint(x: 0.53451*width, y: 0.03052*height),control2: CGPoint(x: 0.56186*width, y: 0.04501*height))
				path.addLine(to: CGPoint(x: 0.96225*width, y: 0.82572*height))
				path.addCurve(to: CGPoint(x: 0.97396*width, y: 0.87401*height),control1: CGPoint(x: 0.97055*width, y: 0.84182*height),control2: CGPoint(x: 0.97396*width, y: 0.85899*height))
				path.addCurve(to: CGPoint(x: 0.889*width, y: 0.96899*height),control1: CGPoint(x: 0.97396*width, y: 0.92445*height),control2: CGPoint(x: 0.9393*width, y: 0.96899*height))
				path.addLine(to: CGPoint(x: 0.12094*width, y: 0.96899*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.50473*width, y: 0.64865*height))
				path.addCurve(to: CGPoint(x: 0.51938*width, y: 0.62826*height),control1: CGPoint(x: 0.51303*width, y: 0.64865*height),control2: CGPoint(x: 0.51938*width, y: 0.6406*height))
				path.addLine(to: CGPoint(x: 0.52231*width, y: 0.33422*height))
				path.addCurve(to: CGPoint(x: 0.50473*width, y: 0.31437*height),control1: CGPoint(x: 0.52231*width, y: 0.32242*height),control2: CGPoint(x: 0.51596*width, y: 0.31437*height))
				path.addCurve(to: CGPoint(x: 0.48715*width, y: 0.33422*height),control1: CGPoint(x: 0.49398*width, y: 0.31437*height),control2: CGPoint(x: 0.48715*width, y: 0.32242*height))
				path.addLine(to: CGPoint(x: 0.49008*width, y: 0.62826*height))
				path.addCurve(to: CGPoint(x: 0.50473*width, y: 0.64865*height),control1: CGPoint(x: 0.49008*width, y: 0.6406*height),control2: CGPoint(x: 0.49643*width, y: 0.64865*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.50473*width, y: 0.79889*height))
				path.addCurve(to: CGPoint(x: 0.53549*width, y: 0.76509*height),control1: CGPoint(x: 0.52182*width, y: 0.79889*height),control2: CGPoint(x: 0.53549*width, y: 0.78226*height))
				path.addCurve(to: CGPoint(x: 0.50473*width, y: 0.73128*height),control1: CGPoint(x: 0.53549*width, y: 0.74685*height),control2: CGPoint(x: 0.52182*width, y: 0.73128*height))
				path.addCurve(to: CGPoint(x: 0.47397*width, y: 0.76509*height),control1: CGPoint(x: 0.48764*width, y: 0.73128*height),control2: CGPoint(x: 0.47397*width, y: 0.74685*height))
				path.addCurve(to: CGPoint(x: 0.50473*width, y: 0.79889*height),control1: CGPoint(x: 0.47397*width, y: 0.78226*height),control2: CGPoint(x: 0.48764*width, y: 0.79889*height))
				path.closeSubpath()
			}
			
			return path
		}
	}
	
	public struct Checkmark: Shape {
		private let size: Size
		public init(_ size: Size) {
			self.size = size
		}
		
		public func path(in rect: CGRect) -> Path{
			var path = Path()
			let width = rect.size.width
			let height = rect.size.height
			
			switch size {
			case .small:
				path.move(to: CGPoint(x: 0.49715*width, y: 0.99767*height))
				path.addCurve(to: CGPoint(x: 0.98689*width, y: 0.50298*height),control1: CGPoint(x: 0.76522*width, y: 0.99767*height),control2: CGPoint(x: 0.98689*width, y: 0.77375*height))
				path.addCurve(to: CGPoint(x: 0.49666*width, y: 0.00829*height),control1: CGPoint(x: 0.98689*width, y: 0.23221*height),control2: CGPoint(x: 0.76522*width, y: 0.00829*height))
				path.addCurve(to: CGPoint(x: 0.0074*width, y: 0.50298*height),control1: CGPoint(x: 0.22859*width, y: 0.00829*height),control2: CGPoint(x: 0.0074*width, y: 0.23221*height))
				path.addCurve(to: CGPoint(x: 0.49715*width, y: 0.99767*height),control1: CGPoint(x: 0.0074*width, y: 0.77375*height),control2: CGPoint(x: 0.22908*width, y: 0.99767*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.49715*width, y: 0.93405*height))
				path.addCurve(to: CGPoint(x: 0.07088*width, y: 0.50298*height),control1: CGPoint(x: 0.26082*width, y: 0.93405*height),control2: CGPoint(x: 0.07088*width, y: 0.74169*height))
				path.addCurve(to: CGPoint(x: 0.49666*width, y: 0.0724*height),control1: CGPoint(x: 0.07088*width, y: 0.26426*height),control2: CGPoint(x: 0.26082*width, y: 0.0724*height))
				path.addCurve(to: CGPoint(x: 0.92391*width, y: 0.50298*height),control1: CGPoint(x: 0.73299*width, y: 0.0724*height),control2: CGPoint(x: 0.92342*width, y: 0.26426*height))
				path.addCurve(to: CGPoint(x: 0.49715*width, y: 0.93405*height),control1: CGPoint(x: 0.92391*width, y: 0.74169*height),control2: CGPoint(x: 0.73348*width, y: 0.93405*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.43416*width, y: 0.74909*height))
				path.addCurve(to: CGPoint(x: 0.46492*width, y: 0.73134*height),control1: CGPoint(x: 0.44686*width, y: 0.74909*height),control2: CGPoint(x: 0.45711*width, y: 0.74317*height))
				path.addLine(to: CGPoint(x: 0.71834*width, y: 0.33134*height))
				path.addCurve(to: CGPoint(x: 0.72713*width, y: 0.30717*height),control1: CGPoint(x: 0.72322*width, y: 0.32394*height),control2: CGPoint(x: 0.72713*width, y: 0.31556*height))
				path.addCurve(to: CGPoint(x: 0.69588*width, y: 0.27807*height),control1: CGPoint(x: 0.72713*width, y: 0.28942*height),control2: CGPoint(x: 0.7115*width, y: 0.27807*height))
				path.addCurve(to: CGPoint(x: 0.66902*width, y: 0.29583*height),control1: CGPoint(x: 0.68563*width, y: 0.27807*height),control2: CGPoint(x: 0.67586*width, y: 0.28399*height))
				path.addLine(to: CGPoint(x: 0.4327*width, y: 0.67264*height))
				path.addLine(to: CGPoint(x: 0.30477*width, y: 0.51334*height))
				path.addCurve(to: CGPoint(x: 0.27693*width, y: 0.49805*height),control1: CGPoint(x: 0.29647*width, y: 0.50249*height),control2: CGPoint(x: 0.28768*width, y: 0.49805*height))
				path.addCurve(to: CGPoint(x: 0.24666*width, y: 0.52912*height),control1: CGPoint(x: 0.26033*width, y: 0.49805*height),control2: CGPoint(x: 0.24666*width, y: 0.51136*height))
				path.addCurve(to: CGPoint(x: 0.25594*width, y: 0.55378*height),control1: CGPoint(x: 0.24666*width, y: 0.538*height),control2: CGPoint(x: 0.25008*width, y: 0.54638*height))
				path.addLine(to: CGPoint(x: 0.40193*width, y: 0.73134*height))
				path.addCurve(to: CGPoint(x: 0.43416*width, y: 0.74909*height),control1: CGPoint(x: 0.41219*width, y: 0.74416*height),control2: CGPoint(x: 0.42195*width, y: 0.74909*height))
				path.closeSubpath()
			case .visual:
				path.move(to: CGPoint(x: 0.49633*width, y: 0.99736*height))
				path.addCurve(to: CGPoint(x: 0.98461*width, y: 0.50354*height),control1: CGPoint(x: 0.76439*width, y: 0.99736*height),control2: CGPoint(x: 0.98461*width, y: 0.77487*height))
				path.addCurve(to: CGPoint(x: 0.49583*width, y: 0.00973*height),control1: CGPoint(x: 0.98461*width, y: 0.23222*height),control2: CGPoint(x: 0.76439*width, y: 0.00973*height))
				path.addCurve(to: CGPoint(x: 0.00755*width, y: 0.50354*height),control1: CGPoint(x: 0.22778*width, y: 0.00973*height),control2: CGPoint(x: 0.00755*width, y: 0.23222*height))
				path.addCurve(to: CGPoint(x: 0.49633*width, y: 0.99736*height),control1: CGPoint(x: 0.00755*width, y: 0.77487*height),control2: CGPoint(x: 0.22778*width, y: 0.99736*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.49633*width, y: 0.9586*height))
				path.addCurve(to: CGPoint(x: 0.04542*width, y: 0.50354*height),control1: CGPoint(x: 0.24721*width, y: 0.9586*height),control2: CGPoint(x: 0.04542*width, y: 0.75473*height))
				path.addCurve(to: CGPoint(x: 0.49583*width, y: 0.04849*height),control1: CGPoint(x: 0.04542*width, y: 0.25236*height),control2: CGPoint(x: 0.24721*width, y: 0.04849*height))
				path.addCurve(to: CGPoint(x: 0.94674*width, y: 0.50354*height),control1: CGPoint(x: 0.74496*width, y: 0.04849*height),control2: CGPoint(x: 0.94674*width, y: 0.25236*height))
				path.addCurve(to: CGPoint(x: 0.49633*width, y: 0.9586*height),control1: CGPoint(x: 0.94674*width, y: 0.75473*height),control2: CGPoint(x: 0.74496*width, y: 0.9586*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.43007*width, y: 0.75423*height))
				path.addCurve(to: CGPoint(x: 0.45*width, y: 0.74315*height),control1: CGPoint(x: 0.43754*width, y: 0.75423*height),control2: CGPoint(x: 0.44452*width, y: 0.75121*height))
				path.addLine(to: CGPoint(x: 0.72453*width, y: 0.31326*height))
				path.addCurve(to: CGPoint(x: 0.72951*width, y: 0.29867*height),control1: CGPoint(x: 0.72752*width, y: 0.30874*height),control2: CGPoint(x: 0.72951*width, y: 0.3032*height))
				path.addCurve(to: CGPoint(x: 0.70958*width, y: 0.27904*height),control1: CGPoint(x: 0.72951*width, y: 0.28659*height),control2: CGPoint(x: 0.71905*width, y: 0.27904*height))
				path.addCurve(to: CGPoint(x: 0.69164*width, y: 0.29011*height),control1: CGPoint(x: 0.70261*width, y: 0.27904*height),control2: CGPoint(x: 0.69613*width, y: 0.28306*height))
				path.addLine(to: CGPoint(x: 0.42907*width, y: 0.70238*height))
				path.addLine(to: CGPoint(x: 0.2796*width, y: 0.52519*height))
				path.addCurve(to: CGPoint(x: 0.26116*width, y: 0.51613*height),control1: CGPoint(x: 0.27412*width, y: 0.51865*height),control2: CGPoint(x: 0.26863*width, y: 0.51613*height))
				path.addCurve(to: CGPoint(x: 0.24123*width, y: 0.53626*height),control1: CGPoint(x: 0.25169*width, y: 0.51613*height),control2: CGPoint(x: 0.24123*width, y: 0.52368*height))
				path.addCurve(to: CGPoint(x: 0.24771*width, y: 0.55288*height),control1: CGPoint(x: 0.24123*width, y: 0.5418*height),control2: CGPoint(x: 0.24372*width, y: 0.54784*height))
				path.addLine(to: CGPoint(x: 0.41014*width, y: 0.74366*height))
				path.addCurve(to: CGPoint(x: 0.43007*width, y: 0.75423*height),control1: CGPoint(x: 0.41711*width, y: 0.75171*height),control2: CGPoint(x: 0.42259*width, y: 0.75423*height))
				path.closeSubpath()

			case .large:
				path.move(to: CGPoint(x: 0.50057*width, y: 0.99174*height))
				path.addCurve(to: CGPoint(x: 0.99343*width, y: 0.49837*height),control1: CGPoint(x: 0.77167*width, y: 0.99174*height),control2: CGPoint(x: 0.99343*width, y: 0.76998*height))
				path.addCurve(to: CGPoint(x: 0.50057*width, y: 0.00551*height),control1: CGPoint(x: 0.99343*width, y: 0.22728*height),control2: CGPoint(x: 0.77167*width, y: 0.00551*height))
				path.addCurve(to: CGPoint(x: 0.00771*width, y: 0.49837*height),control1: CGPoint(x: 0.22947*width, y: 0.00551*height),control2: CGPoint(x: 0.00771*width, y: 0.22728*height))
				path.addCurve(to: CGPoint(x: 0.50057*width, y: 0.99174*height),control1: CGPoint(x: 0.00771*width, y: 0.76998*height),control2: CGPoint(x: 0.22947*width, y: 0.99174*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.50057*width, y: 0.96682*height))
				path.addCurve(to: CGPoint(x: 0.03263*width, y: 0.49837*height),control1: CGPoint(x: 0.2427*width, y: 0.96682*height),control2: CGPoint(x: 0.03263*width, y: 0.75675*height))
				path.addCurve(to: CGPoint(x: 0.50057*width, y: 0.03044*height),control1: CGPoint(x: 0.03263*width, y: 0.2405*height),control2: CGPoint(x: 0.2427*width, y: 0.03044*height))
				path.addCurve(to: CGPoint(x: 0.96851*width, y: 0.49837*height),control1: CGPoint(x: 0.75895*width, y: 0.03044*height),control2: CGPoint(x: 0.96851*width, y: 0.2405*height))
				path.addCurve(to: CGPoint(x: 0.50057*width, y: 0.96682*height),control1: CGPoint(x: 0.96851*width, y: 0.75675*height),control2: CGPoint(x: 0.75895*width, y: 0.96682*height))
				path.closeSubpath()
				path.move(to: CGPoint(x: 0.43241*width, y: 0.75167*height))
				path.addCurve(to: CGPoint(x: 0.44615*width, y: 0.74404*height),control1: CGPoint(x: 0.4375*width, y: 0.75167*height),control2: CGPoint(x: 0.44259*width, y: 0.75014*height))
				path.addLine(to: CGPoint(x: 0.73505*width, y: 0.29848*height))
				path.addCurve(to: CGPoint(x: 0.7381*width, y: 0.28882*height),control1: CGPoint(x: 0.73708*width, y: 0.29543*height),control2: CGPoint(x: 0.7381*width, y: 0.29187*height))
				path.addCurve(to: CGPoint(x: 0.72386*width, y: 0.27407*height),control1: CGPoint(x: 0.7381*width, y: 0.27966*height),control2: CGPoint(x: 0.73047*width, y: 0.27407*height))
				path.addCurve(to: CGPoint(x: 0.71063*width, y: 0.28221*height),control1: CGPoint(x: 0.71877*width, y: 0.27407*height),control2: CGPoint(x: 0.71368*width, y: 0.27712*height))
				path.addLine(to: CGPoint(x: 0.43191*width, y: 0.7125*height))
				path.addLine(to: CGPoint(x: 0.26864*width, y: 0.52635*height))
				path.addCurve(to: CGPoint(x: 0.25541*width, y: 0.52024*height),control1: CGPoint(x: 0.26508*width, y: 0.52177*height),control2: CGPoint(x: 0.26101*width, y: 0.52024*height))
				path.addCurve(to: CGPoint(x: 0.24117*width, y: 0.53448*height),control1: CGPoint(x: 0.24931*width, y: 0.52024*height),control2: CGPoint(x: 0.24117*width, y: 0.52482*height))
				path.addCurve(to: CGPoint(x: 0.24626*width, y: 0.5472*height),control1: CGPoint(x: 0.24117*width, y: 0.53906*height),control2: CGPoint(x: 0.2427*width, y: 0.54364*height))
				path.addLine(to: CGPoint(x: 0.41868*width, y: 0.74506*height))
				path.addCurve(to: CGPoint(x: 0.43241*width, y: 0.75167*height),control1: CGPoint(x: 0.42377*width, y: 0.75065*height),control2: CGPoint(x: 0.42733*width, y: 0.75167*height))
				path.closeSubpath()
			}
			
			return path
		}
	}
}

// MARK: .secondaryColor

public struct SecondaryColorKey: EnvironmentKey {
	public static let defaultValue: Color = Color(uiColor: .systemGray3)
}

public extension EnvironmentValues {
	var secondaryColor: Color {
		get { self[SecondaryColorKey.self] }
		set { self[SecondaryColorKey.self] = newValue }
	}
}

public extension View {
	func secondaryColor(_ color: Color?) -> some View {
		environment(\.secondaryColor, color ?? SecondaryColorKey.defaultValue)
	}
}

// MARK: Previews

#if DEBUG

/*
extension ProgressView.ColorMode {
	fileprivate static var allCases: [Self] {
		[
			.mono(.accentColor),
			.multi,
		]
	}
}
*/

fileprivate struct DemoValue: Hashable, Identifiable {
	var name: String
	var id: String { name }
	static let demo: Self = .init(name: "Demo")
}
fileprivate typealias DemoBackendFetchState = BackendFetchState<DemoValue>

fileprivate extension ProgressView {
	init(
		state: DemoBackendFetchState,
		size: Size = .visual,
		color: ColorMode = .mono(.blue)
	) {
		self.init(state: state.asGeneral, size: size, color: color)
	}
}

fileprivate struct DemoProgressView: View {
	let size: ProgressView.Size
	let color: ProgressView.ColorMode
	@State var value: Double = 0.01
	
	var body: some View {
		ProgressView(value, size, color)
			.animateForever(
				assigning: 0.99,
				to: $value,
				using: .easeInOut(duration: 6),
				autoreverses: true
			)
	}
}

/*
struct ProgressView_Previews: PreviewProvider {
	fileprivate static let states: [DemoBackendFetchState] = [
		.idle,
		.progressZero,
		.progressUndetermined,
		.progressHalf,
		.progressComplete,
		.success(.demo),
		.failed("Demo failure reason"),
	]
	
	fileprivate static var progresses: [FetchProgress] {
		[
			.none,
			.undetermined,
			.complete,
			0,
			0.3,
			1,
		]
	}
	
	static var previews: some View {
		Group {
			ScrollView {
				VStack(alignment: .leading, spacing: 16) {
					ForEach(ProgressView.ColorMode.allCases) { color in
						VStack(alignment: .leading, spacing: 16) {
							ForEach(ProgressView.Size.allCases) { size in
								HStack(alignment: .center, spacing: 16) {
									ProgressView(
										.undetermined,
										size,
										color
									)
									DemoProgressView(
										size: size,
										color: color
									)
									ProgressView(
										state: .failed("Demo failure reason"),
										size: size,
										color: color
									)
									ProgressView(
										.complete,
										size,
										color
									)
									Spacer()
								}
								.background(.bottom) {
									Color.systemGray5
										.height(1)
										.offset(y: 8)
								}
							}
						}
						.padding()
						.padding(.vertical, 1)
						.systemBackground()
						.previewAllColorSchemes()
					}
				}
			}
			.edgesIgnoringSafeArea(.bottom)
			.previewLayout(.sizeThatFits)
		}
		.accentColor(.pink)
		.secondaryColor(Color(uiColor: .systemGray4))
	}
	
	/*
	static var previews: some View {
		Group {
			VStack(alignment: .leading, spacing: 16) {
				Text("States").foregroundStyle(.tint)
				ForEach(states) { state in
					HStack {
						state.id.labeledView()
						Spacer()
						ProgressView(state: state)
					}
					.background(aligned: .bottom, Color(uiColor: .systemGray5).height(1).offset(y: 8))
				}
				
				Text("Progresses").foregroundStyle(.tint)
				ForEach(hashing: progresses) { _, progress in
					HStack {
						progress.labeledView()
						Spacer()
						ProgressView(progress: progress)
					}
					.background(aligned: .bottom, Color(uiColor: .systemGray5).height(1).offset(y: 8))
				}
				
				Text("Sizes").foregroundStyle(.tint)
				ForEach(ProgressView.Size.allCases, id: \.self) { size in
					HStack(alignment: .center, spacing: 16) {
						size.labeledView(label: "Size")
						Spacer()
						ProgressView(state: .progressUndetermined, size: size)
						DemoProgressView(size: size)
						ProgressView(state: .failed("Demo failure reason"), size: size)
						ProgressView(state: .success(.demo), size: size)
					}
					.background(aligned: .bottom, Color(uiColor: .systemGray5).height(1).offset(y: 8))
				}
			}
			
			ProgressView(progress: .complete, size: .visual)
		}
		.previewFitting()
//		.previewAllColorSchemes()
		.accentColor(.pink)
		.secondaryColor(Color(uiColor: .systemGray4))
	}
	*/
}
*/
#endif
