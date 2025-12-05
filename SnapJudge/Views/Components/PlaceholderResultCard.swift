//
//  PlaceholderResultCard.swift
//  SnapJudge
//
//  Created by Christopher Endress on 12/4/25.
//

import SwiftUI

struct PlaceholderResultCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Awaiting analysis")
                .font(.headline)
            
            Text("Once you upload an image and tap Analyze, your feasibility score, cost estimate, and verdict will appear here.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    PlaceholderResultCard()
}
