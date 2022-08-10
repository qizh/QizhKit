//
//  Date+format.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 04.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Date {
	func format(
		    date: DateFormatter.Style = .none,
		    time: DateFormatter.Style = .none,
		relative: Bool = true,
		 context: Formatter.Context = .dynamic,
		    zone: TimeZone = .autoupdatingCurrent,
		  locale: Locale   = .autoupdatingCurrent
	) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle                  = date
		dateFormatter.timeStyle                  = time
		dateFormatter.doesRelativeDateFormatting = relative
		dateFormatter.formattingContext          = context
		dateFormatter.timeZone                   = zone
		dateFormatter.locale                     = locale
		
		return dateFormatter.string(from: self)
	}
	
	func format(
		_ template: String,
		  relative: Bool = true,
		   context: Formatter.Context = .dynamic,
		      zone: TimeZone = .autoupdatingCurrent,
		    locale: Locale   = .autoupdatingCurrent
	) -> String {
		if relative {
			let relativeOutput = format(
				    date: .medium,
				relative: true,
				 context: context,
				    zone: zone,
				  locale: locale
			)
			
			let nonRelativeOutput = format(
				    date: .medium,
				relative: false,
				 context: context,
				    zone: zone,
				  locale: locale
			)
			
			if relativeOutput != nonRelativeOutput {
				return relativeOutput
			}
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.formattingContext = context
		dateFormatter.timeZone          = zone
		dateFormatter.locale            = locale
		dateFormatter.setLocalizedDateFormatFromTemplate(template)
		
		return dateFormatter.string(from: self)
	}
	
	@inlinable func canUseShortestTime(in locale: Locale) -> Bool {
		isHourStart && locale.isUsing12HFormat
	}
	
	func formatShortestTime(
		context: Formatter.Context = .dynamic,
		   zone: TimeZone = .autoupdatingCurrent,
		 locale: Locale   = .autoupdatingCurrent
	) -> String {
		canUseShortestTime(in: locale)
		? format("j",
			 relative: false,
			  context: context,
			   locale: locale)
		: format(time: .short,
			  context: context,
			   locale: locale)
	}
}

public extension DateInterval {
	func format(
		date: DateIntervalFormatter.Style = .none,
		time: DateIntervalFormatter.Style = .none,
		zone: TimeZone = .autoupdatingCurrent,
	  locale: Locale   = .autoupdatingCurrent
	) -> String {
		let formatter = DateIntervalFormatter()
		formatter.dateStyle = date
		formatter.timeStyle = time
		formatter.timeZone  = zone
		formatter.locale    = locale
		return formatter.string(for: self).orEmpty
	}
	
	func format(
		_ template: String,
		      zone: TimeZone = .autoupdatingCurrent,
			locale: Locale   = .autoupdatingCurrent
	) -> String {
		let dif = DateIntervalFormatter()
		dif.dateTemplate = template
		dif.timeZone     = zone
		dif.locale       = locale
		return dif.string(for: self).orEmpty
	}
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.FormatStyle {
	public func capitalizationContext(_ context: FormatStyleCapitalizationContext) -> Date.FormatStyle {
		var copy = self
		copy.capitalizationContext = context
		return copy
	}
}
