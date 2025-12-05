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
                    
                    SnapImagePickerView(
                        viewModel: viewModel,
                        selectedPhotoItem: $selectedPhotoItem,
                        hasSelectedImage: $hasSelectedImage
                    )

                    AnalyzeButtonView(viewModel: viewModel)
                    
                    if let error = viewModel.errorMessage {
                        ErrorBannerView(message: error)
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

// MARK: - Preview

#Preview {
    SnapJudgeRootView()
}
