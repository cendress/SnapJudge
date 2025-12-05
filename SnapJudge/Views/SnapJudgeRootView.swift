//
//  SnapJudgeRootView.swift
//  SnapJudge
//
//  Created by Christopher Endress on 12/4/25.
//

import PhotosUI
import UIKit
import SwiftUI

struct SnapJudgeRootView: View {
    @StateObject private var viewModel = SnapJudgeViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var hasSelectedImage: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    SnapJudgeRootHeaderView()
                    
                    imagePickerSection
                    
                    analyzeButton
                    
                    if let error = viewModel.errorMessage {
//                        ErrorBannerView(message: error)
                    }
                    
                    if let result = viewModel.analysisResult {
                        AnalysisResultCard(result: result)
                    } else {
                        PlaceholderResultCard()
                    }
                }
                .padding()
            }
            .navigationTitle("SnapJudge")
        }
    }
}

// MARK: - Sections

private extension SnapJudgeRootView {
    var imagePickerSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .imageScale(.large)
                    Text(hasSelectedImage ? "Change Image" : "Select Screenshot or Photo")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6])))
            }
            
            if hasSelectedImage, let uiImage = viewModel.selectedImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 4)
            } else {
                Text("No image selected yet.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onChange(of: selectedPhotoItem) { oldItem, newItem in
            if let item = newItem {
                Task {
                    await loadImage(from: item)
                }
            } else {
                Task {
                    await MainActor.run {
                        viewModel.selectedImage = nil
                        hasSelectedImage = false
                    }
                }
            }
        }
    }
    
    var analyzeButton: some View {
        PrimaryButton(
            title: viewModel.isAnalyzing ? "Analyzing..." : "Analyze Idea",
            isLoading: viewModel.isAnalyzing,
            isEnabled: viewModel.canAnalyze
        ) {
            viewModel.runAnalysis()
        }
    }
}

// MARK: - Helpers

private extension SnapJudgeRootView {
    func loadImage(from item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                await MainActor.run {
                    viewModel.selectedImage = uiImage
                    hasSelectedImage = true
                }
            } else {
                await MainActor.run {
                    viewModel.selectedImage = nil
                    hasSelectedImage = false
                }
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }
}

// MARK: - Reusable Components

struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            guard isEnabled && !isLoading else { return }
            action()
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "sparkles")
                }
                
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? Color.accentColor : Color.gray.opacity(0.3))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!isEnabled || isLoading)
    }
}

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

// MARK: - Preview

#Preview {
    SnapJudgeRootView()
}
