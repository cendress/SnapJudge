//
//  AnalysisResultCard.swift
//  SnapJudge
//
//  Created by Christopher Endress on 12/4/25.
//

import SwiftUI

struct AnalysisResultCard: View {
    let result: AnalysisResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(result.ideaTitle)
                .font(.headline)
            
            Text(result.ideaSummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                ScoreRow(
                    label: "Feasibility",
                    valueText: "\(result.feasibilityScore)/100",
                    progress: Double(result.feasibilityScore) / 100.0
                )
                
                ScoreRow(
                    label: "Complexity",
                    valueText: "Level \(result.complexityLevel) / 5",
                    progress: Double(result.complexityLevel) / 5.0
                )
                
                HStack {
                    Label(result.costEstimate, systemImage: "dollarsign.circle")
                    Spacer()
                    Label(result.timeEstimate, systemImage: "clock")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            
            HStack {
                Text("Verdict: ")
                    .fontWeight(.semibold)
                verdictLabel
                Spacer()
            }
            
            Text(result.reasons)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.gray.opacity(0.2))
        )
        .shadow(radius: 2)
    }
    
    private var verdictLabel: some View {
        let color: Color
        switch result.decision {
        case .go: color = .green
        case .noGo: color = .red
        case .maybe: color = .orange
        }
        
        return Text(result.decision.rawValue)
            .font(.subheadline)
            .fontWeight(.bold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview {
    AnalysisResultCard(
        result: AnalysisResult(
            ideaTitle: "AI Travel Planner",
            ideaSummary: "An app that generates personalized travel itineraries using user preferences, budget, and images of destinations.",
            feasibilityScore: 74,
            costEstimate: "$8k–$20k for MVP",
            timeEstimate: "6–10 weeks with 1 developer",
            complexityLevel: 3,
            decision: .go,
            reasons: """
            • Clear demand and defined user segment.
            • Technical complexity moderate — mostly API orchestration + UI.
            • Differentiation depends on UX polish and personalization depth.
            • Monetization via subscriptions is viable.
            """
        )
    )
}
