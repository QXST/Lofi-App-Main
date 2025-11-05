//
//  SegmentedControlView.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import SwiftUI

struct SegmentedControlView: View {
    @Binding var selectedIndex: Int
    let options: [String]

    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedIndex = index
                    }
                }) {
                    Text(option)
                        .font(AppTheme.Typography.body(weight: .semibold))
                        .foregroundColor(selectedIndex == index ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(
                            ZStack {
                                if selectedIndex == index {
                                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                                        .fill(AppTheme.Colors.primary)
                                        .matchedGeometryEffect(id: "segment", in: animation)
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                .fill(AppTheme.Colors.cardLight)
        )
    }
}

#Preview {
    ZStack {
        AppTheme.Gradients.background
            .ignoresSafeArea()

        SegmentedControlView(
            selectedIndex: .constant(0),
            options: ["Radio", "Favorites"]
        )
        .padding()
    }
}
