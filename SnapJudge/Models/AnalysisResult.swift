//
//  AnalysisResult.swift
//  SnapJudge
//
//  Created by Christopher Endress on 12/4/25.
//

import Foundation

enum SnapDecision: String {
    case go = "Go"
    case noGo = "No-Go"
    case maybe = "Maybe"
}

struct AnalysisResult: Identifiable {
    let id = UUID()
    
    let ideaTitle: String
    let ideaSummary: String
    
    // Feasibility score from 0-100
    let feasibilityScore: Int
    
    let costEstimate: String
    let timeEstimate: String
    
    // Complexity level rated from 1-5
    let complexityLevel: Int
    
    let decision: SnapDecision
    let reasons: String
}

extension AnalysisResult {
    // Just some mock data for now
    static var mock: AnalysisResult {
        AnalysisResult(
            ideaTitle: "AI Startup Idea Evaluator",
            ideaSummary: "An app that scores startup ideas from screenshots or notes.",
            feasibilityScore: 82,
            costEstimate: "$5k–$15k to MVP",
            timeEstimate: "4–8 weeks with 1 dev",
            complexityLevel: 3,
            decision: .go,
            reasons: """
            Clear problem, narrow scope, and well-defined users (founders & builders).
            Main challenges are UX polish and AI cost optimization.
            """
        )
    }
}
