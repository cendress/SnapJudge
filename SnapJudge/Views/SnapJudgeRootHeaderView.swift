//
//  SnapJudgeRootHeaderView.swift
//  SnapJudge
//
//  Created by Christopher Endress on 12/4/25.
//

import SwiftUI

struct SnapJudgeRootHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rate any idea in seconds.")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Upload a screenshot or photo of your idea, UI, or notes. SnapJudge will score feasibility, cost, and give you a Go / No-Go verdict.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SnapJudgeRootHeaderView()
}
