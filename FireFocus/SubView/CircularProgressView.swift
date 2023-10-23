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
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.5),
                    lineWidth: 20
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            // 1
                .animation(.easeOut, value: progress)
            
        }
    }
}
