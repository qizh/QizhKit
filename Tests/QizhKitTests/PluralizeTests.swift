//
//  PluralizeTests.swift
//  QizhKit
//
//  Created by GitHub Copilot on 06.12.2025.
//

import Testing
@testable import QizhKit

/// Tests for the Pluralize class and String pluralization extensions.
/// Validates plural/singular transformations, uncountable/unchanging word handling,
/// and dynamic rule additions.
@Suite("Pluralize tests")
struct PluralizeTests {
    
    // MARK: - testPluralizesAndSingularizesCommonWords
    
    /// Verifies that common words are correctly pluralized and singularized,
    /// including both regular and irregular transformations.
    @Test func testPluralizesAndSingularizesCommonWords() async throws {
        // Regular pluralization rules
        #expect("cat".pluralize() == "cats")
        #expect("dog".pluralize() == "dogs")
        #expect("house".pluralize() == "houses")
        
        // Words ending in 'y' preceded by consonant -> 'ies'
        #expect("city".pluralize() == "cities")
        #expect("baby".pluralize() == "babies")
        #expect("party".pluralize() == "parties")
        
        // Words ending in 'x' -> 'xes'
        #expect("box".pluralize() == "boxes")
        #expect("tax".pluralize() == "taxes")
        
        // Words ending in 'sh', 'ss', 'zz' -> 'es'
        #expect("wish".pluralize() == "wishes")
        #expect("class".pluralize() == "classes")
        #expect("buzz".pluralize() == "buzzes")
        
        // Words ending in 'ch' -> 'ches'
        #expect("watch".pluralize() == "watches")
        #expect("church".pluralize() == "churches")
        
        // Irregular plurals
        #expect("tooth".pluralize() == "teeth")
        #expect("foot".pluralize() == "feet")
        #expect("goose".pluralize() == "geese")
        #expect("mouse".pluralize() == "mice")
        #expect("child".pluralize() == "children")
        #expect("person".pluralize() == "people")
        #expect("man".pluralize() == "men")
        #expect("woman".pluralize() == "women")
        #expect("ox".pluralize() == "oxen")
        
        // Words ending in 'f' or 'fe' -> 'ves'
        #expect("knife".pluralize() == "knives")
        #expect("wolf".pluralize() == "wolves")
        #expect("leaf".pluralize() == "leaves")
        #expect("thief".pluralize() == "thieves")
        
        // Latin/Greek endings
        #expect("cactus".pluralize() == "cacti")
        #expect("nucleus".pluralize() == "nuclei")
        #expect("fungus".pluralize() == "fungi")
        #expect("criterion".pluralize() == "criteria")
        #expect("phenomenon".pluralize() == "phenomena")
        
        // Singularization tests
        #expect("cats".singularize() == "cat")
        #expect("dogs".singularize() == "dog")
        #expect("cities".singularize() == "city")
        #expect("boxes".singularize() == "box")
        #expect("wishes".singularize() == "wish")
        #expect("watches".singularize() == "watch")
        #expect("analyses".singularize() == "analysis")
        #expect("diagnoses".singularize() == "diagnosis")
        
        // Count parameter tests
        #expect("cat".pluralize(count: 1) == "cat")
        #expect("cat".pluralize(count: 2) == "cats")
        #expect("cat".pluralize(count: 0) == "cats")
        
        // Custom plural with 'with' parameter
        #expect("person".pluralize(count: 2, with: "persons") == "persons")
    }
    
    // MARK: - testHonorsUncountableAndUnchangingLists
    
    /// Verifies that uncountable and unchanging words remain unchanged
    /// when pluralized or singularized.
    @Test func testHonorsUncountableAndUnchangingLists() async throws {
        // Uncountable words should not change
        #expect("information".pluralize() == "information")
        #expect("equipment".pluralize() == "equipment")
        #expect("news".pluralize() == "news")
        #expect("money".pluralize() == "money")
        #expect("rice".pluralize() == "rice")
        #expect("music".pluralize() == "music")
        #expect("furniture".pluralize() == "furniture")
        #expect("luggage".pluralize() == "luggage")
        #expect("advice".pluralize() == "advice")
        #expect("traffic".pluralize() == "traffic")
        #expect("software".pluralize() == "software")
        #expect("research".pluralize() == "research")
        #expect("knowledge".pluralize() == "knowledge")
        #expect("education".pluralize() == "education")
        
        // Unchanging words (same in singular and plural)
        #expect("sheep".pluralize() == "sheep")
        #expect("deer".pluralize() == "deer")
        #expect("moose".pluralize() == "moose")
        #expect("swine".pluralize() == "swine")
        #expect("bison".pluralize() == "bison")
        #expect("corps".pluralize() == "corps")
        #expect("means".pluralize() == "means")
        #expect("series".pluralize() == "series")
        #expect("scissors".pluralize() == "scissors")
        #expect("species".pluralize() == "species")
        
        // Uncountable singularization should also return unchanged
        #expect("information".singularize() == "information")
        #expect("sheep".singularize() == "sheep")
        
        // Empty string should return unchanged
        #expect("".pluralize() == "")
        #expect("".singularize() == "")
    }
    
    // MARK: - testAddsRuntimeRules
    
    /// Verifies that dynamically added plural and singular rules
    /// are applied ahead of default rules.
    @Test func testAddsRuntimeRules() async throws {
        // Add a custom plural rule for a made-up pattern
        // Note: Rules are added to the front of the list, so they take precedence
        Pluralize.rule(rule: "zoon$", with: "$1zoa")
        #expect("protozoon".pluralize() == "protozoa")
        
        // Add a custom singular rule
        Pluralize.singularRule(rule: "zoa$", with: "zoon")
        #expect("protozoa".singularize() == "protozoon")
        
        // Add a custom uncountable word
        Pluralize.uncountable(word: "customword")
        #expect("customword".pluralize() == "customword")
        
        // Add a custom unchanging word
        Pluralize.unchanging(word: "unchangingtest")
        #expect("unchangingtest".pluralize() == "unchangingtest")
    }
}
