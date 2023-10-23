//
//  roundedSection.swift
//  Meditaste
//
//  Created by Supachod Trakansirorut on 22/10/2566 BE.
//

import SwiftUI

extension View {
    func roundedSection() -> some View {
        modifier(RoundedSection())
    }
}

struct RoundedSection: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(
                Color(UIColor.secondarySystemGroupedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20)))
    }
}
