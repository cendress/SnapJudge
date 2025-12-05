//
//  AnalyzeButtonView.swift
//  SnapJudge
//
//  Created by Christopher Endress on 12/4/25.
//

import SwiftUI

struct AnalyzeButtonView: View {
    @ObservedObject var viewModel: SnapJudgeViewModel
    
    var body: some View {
        PrimaryButton(
            title: viewModel.isAnalyzing ? "Analyzing..." : "Analyze Idea",
            isLoading: viewModel.isAnalyzing,
            isEnabled: viewModel.canAnalyze
        ) {
            viewModel.runAnalysis()
        }
    }
}

//MARK: - Preview

#Preview {
    AnalyzeButtonView(viewModel: SnapJudgeViewModel())
}
