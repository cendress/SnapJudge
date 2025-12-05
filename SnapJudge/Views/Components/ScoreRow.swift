//
//  ScoreRow.swift
//  SnapJudge
//
//  Created by Christopher Endress on 12/4/25.
//

import SwiftUI

struct ScoreRow: View {
    let label: String
    let valueText: String
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                Spacer()
                Text(valueText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: progress)
        }
    }
}

#Preview {
    ScoreRow(label: "Feasibility", valueText: "Example", progress: 50.0)
}
