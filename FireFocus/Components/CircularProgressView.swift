//
//  CircularProgressView.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 23/10/2566 BE.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let color: Color

    private var remainingProgress: Double {
        1 - min(max(progress, 0), 1)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.16),
                    lineWidth: 18
                )
            Circle()
                .trim(from: 0, to: remainingProgress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: 18,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}
