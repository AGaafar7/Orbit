//
//  OrbitIcon.swift
//  Orbit
//
//  Created by Ahmed Gaafar on 25/03/2026.
//


import SwiftUI

struct OrbitIcon: View {
    var body: some View {
        ZStack {
            // macOS Icon Squircle Background
            RoundedRectangle(cornerRadius: 220, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors:[Color(white: 0.2), Color(white: 0.05)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
            
            // Inner glowing grid/background
            RoundedRectangle(cornerRadius: 220, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 4)
            
            // The Orbital Ring
            Ellipse()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.white, .black]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12)
                )
                .frame(width: 700, height: 350)
                .rotationEffect(.degrees(-30))
            
            // Center Core (The "System")
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.white, .black]),
                        center: .topLeading,
                        startRadius: 30,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
        }
        .frame(width: 1024, height: 1024) // Standard macOS App Icon Size
        .padding(50)
        // Background to mimic the Xcode preview canvas
        .background(Color(white: 0.9))
    }
}

#Preview {
    OrbitIcon()
}
