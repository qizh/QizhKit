#if swift(>=6.2) && canImport(Testing)

import Testing
import QizhKit

@Suite("AirtableFormulaBuilder Tests")
struct AirtableFormulaBuilderTests {
        private enum Fields: String, CodingKey {
                case name
                case city
        }

        @Test("Friendly strings producing")
        func testProducesAirtableFriendlyStrings() {
                let equals = AirtableFormulaBuilder.equals("O'Hara", in: Fields.name)
                let notEquals = AirtableFormulaBuilder.notEquals("O'Hara", in: Fields.name)
                let isEmpty = AirtableFormulaBuilder.isEmpty(Fields.city)
                let recordID = AirtableFormulaBuilder.id("recABC123")

                #expect(equals.description == "{name} = 'O\\'Hara'")
                #expect(notEquals.description == "{name} != 'O\\'Hara'")
                #expect(isEmpty.description == "{city} = BLANK()")
                #expect(recordID.description == "RECORD_ID() = 'recABC123'")
        }

        @Test("Using And or Not to combine formulas")
        func testCombinesFormulasWithAndOrNot() {
                let emptyCheck = AirtableFormulaBuilder.isEmpty(Fields.city)
                let nameEquals = AirtableFormulaBuilder.equals("Jean", in: Fields.name)
                let idMatches = AirtableFormulaBuilder.ids(["rec1", "rec2"])

                let combined = AirtableFormulaBuilder.and(
                        nameEquals,
                        emptyCheck.not,
                        idMatches
                )

                #expect(combined.description == "AND({name} = 'Jean', NOT({city} = BLANK()), OR(RECORD_ID() = 'rec1', RECORD_ID() = 'rec2'))")
        }

        @Test("Escaping apostrophes in interpolation")
        func testEscapesApostrophesInInterpolation() {
                enum Borough: String { case queens = "Queen's" }

                let rawEscaped: String = "\(e: "O'Hara")"
                let representableEscaped: String = "\(e: Borough.queens)"
                let formula = "Filter: \(AirtableFormulaBuilder.equals("O'Hara", in: Fields.name))"

                #expect(rawEscaped == "O\\'Hara")
                #expect(representableEscaped == "Queen\\'s")
                #expect(formula.contains("{name} = 'O\\'Hara'"))
        }
}

#endif
