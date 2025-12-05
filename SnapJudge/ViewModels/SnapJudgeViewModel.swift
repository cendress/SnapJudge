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
    @Published var errorMessage: String?
    
    func runAnalysis() {
        guard let image = selectedImage else { return }
        
        isAnalyzing = true
        analysisResult = nil
        errorMessage = nil
        
        Task {
            do {
                let result = try await OpenAIClient.shared.analyzeIdea(from: image)
                self.analysisResult = result
            } catch {
                print("Analysis failed: \(error)")
                self.errorMessage = "Couldn't analyze this image. \(error.localizedDescription)"
            }
            
            self.isAnalyzing = false
        }
    }
    
    var canAnalyze: Bool {
        selectedImage != nil && !isAnalyzing
    }
}
