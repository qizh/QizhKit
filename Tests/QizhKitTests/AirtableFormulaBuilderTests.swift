//
//  AirtableFormulaBuilderTests.swift
//  QizhKit
//
//  Created by Codex.
//

#if swift(>=6.2) && canImport(Testing)

import Testing
import QizhKit

@Suite("Airtable Formula Builder")
struct AirtableFormulaBuilderTests {
	@Test("Airtable-friendly strings producing")
	func testProducesAirtableFriendlyStrings() {
		let equals = AirtableFormulaBuilder.equals("O'Neil", "Name")
		let notEquals = AirtableFormulaBuilder.notEquals("Draft", "Status")
		let isEmpty = AirtableFormulaBuilder.isEmpty("Comment")
		let id = AirtableFormulaBuilder.id("rec123")

		#expect(equals.description == "{Name} = 'O\\'Neil'")
		#expect(notEquals.description == "{Status} != 'Draft'")
		#expect(isEmpty.description == "{Comment} = BLANK()")
		#expect(id.description == "RECORD_ID() = 'rec123'")
	}

	@Test("Combining formulas with And, Or, and Not")
	func testCombinesFormulasWithAndOrNot() {
		let combined = AirtableFormulaBuilder.and(
			.equals("A", "Alpha"),
			.or(
				.notEquals("B", "Beta"),
				.not(.isEmpty("Gamma"))
			)
		)

		#expect(combined.description == "AND({Alpha} = 'A', OR({Beta} != 'B', NOT({Gamma} = BLANK())))")
	}

	@Test("Escaped apostrophes interpolation")
	func testEscapesApostrophesInInterpolation() {
		let formula = AirtableFormulaBuilder.equals("D'Angelo", "Artist")
		let interpolated = "Formula: \(formula)"
		#expect(interpolated == "Formula: {Artist} = 'D\\'Angelo'")

		enum Venue: String {
			case arena = "O'Clock Arena"
		}
		let escapedRawRepresentable = "Venue: \(e: Venue.arena)"
		let escapedStringConvertible = "Alias: \(e: "O'Brien")"

		#expect(escapedRawRepresentable == "Venue: O\\'Clock Arena")
		#expect(escapedStringConvertible == "Alias: O\\'Brien")
	}
}

#endif
