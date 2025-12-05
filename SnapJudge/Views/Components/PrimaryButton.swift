//
//  PrimaryButton.swift
//  SnapJudge
//
//  Created by Christopher Endress on 12/4/25.
//

import SwiftUI

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
                        .foregroundStyle(.black)
                }
                
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? Color("YellowColor") : Color.gray.opacity(0.3))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!isEnabled || isLoading)
    }
}

#Preview {
    PrimaryButton(title: "Analyze", isLoading: false, isEnabled: true, action: {})
}
