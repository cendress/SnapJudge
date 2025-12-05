//
//  SnapImagePickerView.swift
//  SnapJudge
//
//  Created by Christopher Endress on 12/4/25.
//

import PhotosUI
import SwiftUI
import UIKit

struct SnapImagePickerView: View {
    @ObservedObject var viewModel: SnapJudgeViewModel
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var hasSelectedImage: Bool
    
    var body: some View {
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
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                )
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
}

// MARK: - Helpers

private extension SnapImagePickerView {
    func loadImage(from item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    viewModel.selectedImage = uiImage
                    hasSelectedImage = true
                }
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }
}

// MARK: - Preview

struct SnapImagePickerView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var pickerItem: PhotosPickerItem?
        @State private var hasImage: Bool = false
        @StateObject private var viewModel = SnapJudgeViewModel()
        
        var body: some View {
            SnapImagePickerView(
                viewModel: viewModel,
                selectedPhotoItem: $pickerItem,
                hasSelectedImage: $hasImage
            )
            .padding()
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
