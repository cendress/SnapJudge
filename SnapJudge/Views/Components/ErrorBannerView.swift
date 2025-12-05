//
//  ErrorBannerView.swift
//  SnapJudge
//
//  Created by Christopher Endress on 12/4/25.
//

import SwiftUI

struct ErrorBannerView: View {
    let message: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .imageScale(.medium)
            
            Text(message)
                .font(.footnote)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.red.opacity(0.1))
        )
        .foregroundColor(.red)
    }
}

#Preview {
    ErrorBannerView(message: "Something went wrong while contacting the AI. Please try again.")
}
