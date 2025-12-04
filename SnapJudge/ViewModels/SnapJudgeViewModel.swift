//
//  SnapJudgeViewModel.swift
//  SnapJudge
//
//  Created by Christopher Endress on 12/4/25.
//

import Combine
import SwiftUI

@MainActor
final class SnapJudgeViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var analysisResult: AnalysisResult?
    @Published var isAnalyzing: Bool = false
    
    // Later this will trigger a real Vision model + LLM pipeline
    // For Step 1, we just simulate a delay and return mock data
    func runMockAnalysis() {
        guard selectedImage != nil else { return }
        
        isAnalyzing = true
        analysisResult = nil
        
        // Simulate "calling AI" so the UX feels real
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.analysisResult = .mock
            self.isAnalyzing = false
        }
    }
    
    var canAnalyze: Bool {
        selectedImage != nil && !isAnalyzing
    }
}
