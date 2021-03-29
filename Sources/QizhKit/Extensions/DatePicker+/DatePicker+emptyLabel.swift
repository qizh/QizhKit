//
//  File.swift
//  
//
//  Created by Serhii Shevchenko on 29.03.2021.
//

import SwiftUI

public extension DatePicker where Label == EmptyView {
	init(
		selection: Binding<Date>,
		displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]
	) {
		self.init(
			selection: selection,
			displayedComponents: displayedComponents,
			label: EmptyView.init
		)
	}
	
	init(
		selection: Binding<Date>,
		in range: ClosedRange<Date>,
		displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]
	) {
		self.init(
			selection: selection,
			in: range,
			displayedComponents: displayedComponents,
			label: EmptyView.init
		)
	}
	
	init(
		selection: Binding<Date>,
		in range: PartialRangeFrom<Date>,
		displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]
	) {
		self.init(
			selection: selection,
			in: range,
			displayedComponents: displayedComponents,
			label: EmptyView.init
		)
	}
	
	init(
		selection: Binding<Date>,
		in range: PartialRangeThrough<Date>,
		displayedComponents: DatePicker<Label>.Components = [.hourAndMinute, .date]
	) {
		self.init(
			selection: selection,
			in: range,
			displayedComponents: displayedComponents,
			label: EmptyView.init
		)
	}
}
