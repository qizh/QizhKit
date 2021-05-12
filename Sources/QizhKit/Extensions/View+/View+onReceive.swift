//
//  View+onReceive.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 24.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import Combine

// MARK: onChange

/*
@available(iOS 14.0, *)
extension View {
	@inlinable public func onChange <Value: Equatable> (
		of value: Value,
		perform action: @escaping () -> Void
	) -> some View {
		onChange(
			of: value,
			perform: { _ in action() }
		)
	}
}
*/

// MARK: onReceive

public extension View {
	@inlinable func onReceive<P>(
		_ publisher: P,
		perform action: @escaping () -> Void
	) -> some View
		where
			P: Publisher,
			P.Failure == Never
	{
		onReceive(
			publisher,
			perform: { _ in
				action()
			}
		)
	}
	
	@inlinable func onReceiveDefined<OptionalValuePublisher, Value>(
		_ publisher: OptionalValuePublisher,
		perform action: @escaping (Value) -> Void,
		flow: ExecutionFlow = .current
	) -> some View
		where
			OptionalValuePublisher: Publisher,
			OptionalValuePublisher.Output == Value?,
			OptionalValuePublisher.Failure == Never
	{
		onReceive(publisher) { optionalValue in
			optionalValue.map { value in
				flow.proceed(with: action, value)
			}
		}
	}
	
	@inlinable func onReceiveDefined<OptionalValuePublisher, Value>(
		_ publisher: OptionalValuePublisher,
		perform action: @escaping () -> Void,
		flow: ExecutionFlow = .current
	) -> some View
		where
			OptionalValuePublisher: Publisher,
			OptionalValuePublisher.Output == Value?,
			OptionalValuePublisher.Failure == Never
	{
		onReceive(publisher) { optionalValue in
			optionalValue.map { _ in
				flow.proceed(with: action)
			}
		}
	}
	
	@inlinable func onReceiveValue<StatePublisher, Value>(
		_ publisher: StatePublisher,
		perform action: @escaping (Value) -> Void
	) -> some View
		where
			StatePublisher: Publisher,
			StatePublisher.Output == BackendFetchState<Value>,
			StatePublisher.Failure == Never
	{
		onReceive(publisher) { state in
			state.value.map { value in
				action(value)
			}
		}
	}
	
	func onReceiveFirstValue<StatePublisher, Value>(
		_ publisher: StatePublisher,
		perform action: @escaping (Value.Element) -> Void,
		_ flow: ExecutionFlow = .current
	) -> some View
		where
		Value: Collection,
		StatePublisher: Publisher,
		StatePublisher.Output == BackendFetchState<Value>,
		StatePublisher.Failure == Never
	{
		onReceive(publisher) { state in
			state.first.map { first in
				flow.proceed(with: action, first)
			}
		}
	}
	
	func onReceiveFirstValue<StatePublisher, Value>(
		_ publisher: StatePublisher,
		perform action: @escaping () -> Void,
		_ flow: ExecutionFlow = .current
	) -> some View
		where
		Value: Collection,
		StatePublisher: Publisher,
		StatePublisher.Output == BackendFetchState<Value>,
		StatePublisher.Failure == Never
	{
		onReceive(publisher) { state in
			state.first.map { _ in
				flow.proceed(with: action)
			}
		}
	}
	
	// MARK: Assign
	
//	@inlinable
	func assign<NonFailingPublisher, Root, Value>(
		   _ publisher: NonFailingPublisher,
		    to keyPath: ReferenceWritableKeyPath<Root, Value>,
		     on object: Root,
		when condition: Bool = true,
		with animation: Animation? = .none
//		        _ flow: ExecutionFlow = .current
	) -> some View
		where
		NonFailingPublisher: Publisher,
		NonFailingPublisher.Output == Value,
		NonFailingPublisher.Failure == Never
	{
		onReceive(publisher) { value in
			guard condition else { return }
			execute {
				withAnimation(animation) {
					object[keyPath: keyPath] = value
				}
			}
		}
	}
	
//	@inlinable
	func assign<NonFailingPublisher, Root, Value>(
		   _ publisher: NonFailingPublisher,
		    to keyPath: ReferenceWritableKeyPath<Root, Value?>,
		     on object: Root,
		when condition: Bool = true,
		with animation: Animation? = .none
	) -> some View
		where
		NonFailingPublisher: Publisher,
		NonFailingPublisher.Output == Value,
		NonFailingPublisher.Failure == Never
	{
		onReceive(publisher) { value in
			guard condition else { return }
			execute {
				withAnimation(animation) {
					object[keyPath: keyPath] = value
				}
			}
		}
	}
	
//	@inlinable
	func assignValue<StatePublisher, Value, Root>(
		_ publisher: StatePublisher,
		to keyPath: ReferenceWritableKeyPath<Root, Value>,
		on object: Root,
		when condition: Bool = true,
		with animation: Animation? = .none
	) -> some View
		where
		StatePublisher: Publisher,
		StatePublisher.Output == BackendFetchState<Value>,
		StatePublisher.Failure == Never
	{
		onReceive(publisher) { state in
			guard condition else { return }
			state.value.map { value in
				var action: () -> Void = { object[keyPath: keyPath] = value }
				if let animation = animation {
					action = { withAnimation(animation, action) }
				}
				execute(action)
			}
		}
	}
	
//	@inlinable
	func assignValue<StatePublisher, Value, Root>(
		_ publisher: StatePublisher,
		to keyPath: ReferenceWritableKeyPath<Root, Value?>,
		on object: Root,
		when condition: Bool = true,
		with animation: Animation? = .none
	) -> some View
		where
		StatePublisher: Publisher,
		StatePublisher.Output == BackendFetchState<Value>,
		StatePublisher.Failure == Never
	{
		onReceive(publisher) { state in
			guard condition else { return }
			state.value.map { value in
				var action: () -> Void = { object[keyPath: keyPath] = value }
				if let animation = animation {
					action = { withAnimation(animation, action) }
				}
				execute(action)
			}
		}
	}
	
//	@inlinable
	func assignFirstValue<StatePublisher, Value, Root>(
		_ publisher: StatePublisher,
		to keyPath: ReferenceWritableKeyPath<Root, Value.Element>,
		on object: Root,
		when condition: Bool = true,
		with animation: Animation? = .none
	) -> some View
		where
			StatePublisher: Publisher,
			StatePublisher.Output == BackendFetchState<Value>,
			StatePublisher.Failure == Never,
			Value: Collection
	{
		onReceive(publisher) { state in
			guard condition else { return }
			state.first.map { value in
				var action: () -> Void = { object[keyPath: keyPath] = value }
				if let animation = animation {
					action = { withAnimation(animation, action) }
				}
				execute(action)
			}
		}
	}
	
//	@inlinable
	func assignFirstValue<StatePublisher, Value, Root>(
		_ publisher: StatePublisher,
		to keyPath: ReferenceWritableKeyPath<Root, Value.Element?>,
		on object: Root,
		when condition: Bool = true,
		with animation: Animation? = .none
	) -> some View
		where
			StatePublisher: Publisher,
			StatePublisher.Output == BackendFetchState<Value>,
			StatePublisher.Failure == Never,
			Value: Collection
	{
		onReceive(publisher) { state in
			guard condition else { return }
			state.first.map { value in
				var action: () -> Void = { object[keyPath: keyPath] = value }
				if let animation = animation {
					action = { withAnimation(animation, action) }
				}
				execute(action)
			}
		}
	}
	
	// MARK: Assign Binding
	
	func assign <P, Value> (
		   _ publisher: P,
			to binding: Binding<Value>,
		when condition: Bool = true,
		with animation: Animation? = .none,
				  flow: ExecutionFlow = .current
	) -> some View
		where
		P: Publisher,
		P.Output == Value,
		P.Failure == Never
	{
		onReceive(publisher) { value in
			guard condition else { return }
			var closure: () -> Void = { binding.wrappedValue = value }
			if let animation = animation { closure = { withAnimation(animation, closure) } }
			flow.proceed(with: closure)
		}
	}
	
	func assign <P, Value> (
		   _ publisher: P,
			to binding: Binding<Value?>,
		when condition: Bool = true,
		with animation: Animation? = .none,
				  flow: ExecutionFlow = .current
	) -> some View
		where
		P: Publisher,
		P.Output == Value,
		P.Failure == Never
	{
		onReceive(publisher) { value in
			guard condition else { return }
			var closure: () -> Void = { binding.wrappedValue = value }
			if let animation = animation { closure = { withAnimation(animation, closure) } }
			flow.proceed(with: closure)
		}
	}

	// MARK: on (Dis) Appear
	
	@ViewBuilder
	func whenAppear(
		perform action: (() -> Void)? = nil
	) -> some View {
		switch action {
		case .none: self
		case .some(let action): self.onAppear(perform: action)
		}
	}
	
	@ViewBuilder
	func whenAppear(
		if condition: Bool,
		perform action: (() -> Void)? = nil
	) -> some View {
		if condition {
			onAppear(perform: action)
		} else {
			self
		}
	}
	
	@inlinable func whenAppear(perform action: @escaping () -> Void, in ms: Int) -> some View {
		onAppear {
			execute(in: ms, action)
		}
	}
	
	@inlinable func whenAppear(in ms: Int, _ action: @escaping () -> Void) -> some View {
		onAppear {
			execute(in: ms, action)
		}
	}
	
	@inlinable func onDisappear(in ms: Int, _ action: @escaping () -> Void) -> some View {
		onDisappear {
			execute(in: ms, action)
		}
	}
	
	@inlinable func whenAppear <Value, Root> (
		when cond: Bool = true,
	  assign  val: @autoclosure @escaping () -> Value,
		  to  key: ReferenceWritableKeyPath<Root, Value>,
		  on root: Root,
		with anim: Animation? = .none,
			 flow: ExecutionFlow = .current
	) -> some View {
		onAppear {
			guard cond else { return }
			var exe: () -> Void = { root[keyPath: key] = val() }
			if let ani = anim { exe = { withAnimation(ani, exe) } }
			flow.proceed(with: exe)
			
			/*
			guard condition else { return }
			
			let assignment = {
				root[keyPath: key] = value()
			}
			
			switch (animation, ms) {
			case (.none, let ms) where ms <= 0:
				execute(assignment)
			case (.none, let ms):
				execute(in: ms, assignment)
			case (.some(let animation), let ms) where ms <= 0:
				execute {
					withAnimation(animation, assignment)
				}
			case (.some(let animation), let ms):
				execute(in: ms) {
					withAnimation(animation, assignment)
				}
			}
			*/
		}
	}
	
	func whenAppear <Value> (
		when condition: Bool = true,
	  assign     value: @autoclosure @escaping () -> Value,
		  to    target: Binding<Value>,
		with animation: Animation? = .none,
				  flow: ExecutionFlow = .current
	) -> some View {
		onAppear {
			guard condition else { return }
			var command: () -> Void = { target.wrappedValue = value() }
			if let animation = animation { command = { withAnimation(animation, command) } }
			flow.proceed(with: command)
		}
	}
	
	func onAppear <Value> (
		when condition: Bool = true,
	  assign     value: @autoclosure @escaping () -> Value?,
		  to    target: Binding<Value>,
		with animation: Animation? = .none,
				  flow: ExecutionFlow = .current
	) -> some View {
		onAppear {
			guard condition else { return }
			var command: () -> Void = { if let value = value() { target.wrappedValue = value } }
			if let animation = animation { command = { withAnimation(animation, command) } }
			flow.proceed(with: command)
		}
	}
	
	func onDisappear <Value, Root> (
		  when cond: Bool = true,
		assign  val: @autoclosure @escaping () -> Value,
			to  key: ReferenceWritableKeyPath<Root, Value>,
		    on root: Root,
		  with anim: Animation? = .none,
		       flow: ExecutionFlow = .current
	) -> some View {
		onDisappear {
			guard cond else { return }
			var exe: () -> Void = { root[keyPath: key] = val() }
			if let ani = anim { exe = { withAnimation(ani, exe) } }
			flow.proceed(with: exe)
		}
	}
	
	// MARK: > Assign Binding
	
	func onAppear <Value> (
		  when cond: Bool = true,
		assign  val: @autoclosure @escaping () -> Value,
		 to binding: Binding<Value>,
		  with anim: Animation? = .none,
			   flow: ExecutionFlow = .current
	) -> some View {
		onAppear {
			guard cond else { return }
			var exe: () -> Void = { binding.wrappedValue = val() }
			if let ani = anim { exe = { withAnimation(ani, exe) } }
			flow.proceed(with: exe)
		}
	}
	
	func onDisappear <Value> (
		  when cond: Bool = true,
		assign  val: @autoclosure @escaping () -> Value,
		 to binding: Binding<Value>,
		  with anim: Animation? = .none,
			   flow: ExecutionFlow = .current
	) -> some View {
		onDisappear {
			guard cond else { return }
			var exe: () -> Void = { binding.wrappedValue = val() }
			if let ani = anim { exe = { withAnimation(ani, exe) } }
			flow.proceed(with: exe)
		}
	}
	
	// MARK: > Reset Binding<Optional>
	
	func onAppear <Value> (
			when cond: Bool = true,
		reset binding: Binding<Value?>,
			with anim: Animation? = .none,
				 flow: ExecutionFlow = .current
	) -> some View {
		onAppear {
			guard cond else { return }
			var exe: () -> Void = { binding.wrappedValue = .none }
			if let ani = anim { exe = { withAnimation(ani, exe) } }
			flow.proceed(with: exe)
		}
	}
	
	func onDisappear <Value> (
		    when cond: Bool = true,
		reset binding: Binding<Value?>,
		    with anim: Animation? = .none,
			     flow: ExecutionFlow = .current
	) -> some View {
		onDisappear {
			guard cond else { return }
			var exe: () -> Void = { binding.wrappedValue = .none }
			if let ani = anim { exe = { withAnimation(ani, exe) } }
			flow.proceed(with: exe)
		}
	}
	
	// MARK: > Toggle Binding<Bool>
	
	func onAppear(
			 when cond: Bool = true,
		toggle binding: Binding<Bool>,
			 with anim: Animation? = .none,
				  flow: ExecutionFlow = .current
	) -> some View {
		onAppear {
			guard cond else { return }
			var exe: () -> Void = { binding.toggle() }
			if let ani = anim { exe = { withAnimation(ani, exe) } }
			flow.proceed(with: exe)
		}
	}
	
	func onDisappear(
			 when cond: Bool = true,
		toggle binding: Binding<Bool>,
			 with anim: Animation? = .none,
				  flow: ExecutionFlow = .current
	) -> some View {
		onDisappear {
			guard cond else { return }
			var exe: () -> Void = { binding.toggle() }
			if let ani = anim { exe = { withAnimation(ani, exe) } }
			flow.proceed(with: exe)
		}
	}
	
	// MARK: Print
	
	func onAppear(print message: String) -> some View {
		onAppear(perform: {
			print(message)
		})
	}
	
	func onDisappear(print message: String) -> some View {
		onDisappear(perform: {
			print(message)
		})
	}
}

/*
//@available(iOS 14.0, *)
public struct AppearWorkaround: ViewModifier {
	public typealias Action = () -> Void
	private let action: Action?
	
	@State private var isFirstTime = true
//	@State private var lastFired: Date = Date.reference0
	@Environment(\.presentationMode) private var presentation
	
	public init(
		perform action: Action? = .none
	) {
		self.action = action
	}
	
	public func body(content: Content) -> some View {
		content
			.onAppear  {
				if presentation.wrappedValue.isPresented || isFirstTime {
					isFirstTime = false
					self.action?()
				}

				/*
				let now: Date = .now
				let timePassed = lastFired.distance(to: now)
				print("=== timePassed: \(timePassed)")
				let canFire = lastFired.isReference0
					|| presentation.wrappedValue.isPresented && timePassed > 100
				if canFire {
					lastFired = now
					self.action?()
				}
				*/
			}
			/*
			.onChange(of: presentation.wrappedValue.isPresented) { isPresented in
				
			}
			*/
	}
}
*/
