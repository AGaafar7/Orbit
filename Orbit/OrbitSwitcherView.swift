//
//  OrbitSwitcherView.swift
//  Orbit
//
//  Created by Ahmed Gaafar on 25/03/2026.
//


import SwiftUI

struct OrbitSwitcherView: View {
    @EnvironmentObject var manager: OrbitOverlayManager
    
    let radius: CGFloat = 350
    let baseIconSize: CGFloat = 64
    
    var body: some View {
        ZStack {
            Color.clear
            
            if manager.apps.isEmpty {
                Text("No Running Apps")
                    .font(.title2)
                    .foregroundColor(.white)
            } else {
                ForEach(Array(manager.apps.enumerated()), id: \.element.id) { index, appInfo in
                    let isSelected = index == manager.selectedIndex
                    let angle = calculateAngle(for: index, selectedIndex: manager.selectedIndex, total: manager.apps.count)
                    let xOffset = cos(angle) * radius
                    let yOffset = (sin(angle) * radius) + radius - 50
                    
                    Image(nsImage: appInfo.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: isSelected ? baseIconSize * 1.8 : baseIconSize,
                               height: isSelected ? baseIconSize * 1.8 : baseIconSize)
                        .opacity(isSelected ? 1.0 : 0.4)
                        .shadow(color: isSelected ? .black.opacity(0.8) : .clear, radius: 10, x: 0, y: 5)
                        .offset(x: xOffset, y: yOffset)
                        .zIndex(isSelected ? 1 : 0)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: manager.selectedIndex)
                }
                
                if manager.apps.indices.contains(manager.selectedIndex) {
                    Text(manager.apps[manager.selectedIndex].name)
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 6, x: 0, y: 2)
                        .offset(y: 80) // Places it directly below the center icon
                        .animation(.none, value: manager.selectedIndex)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
    
    /// Math logic to generate the smooth rotating arc layout
    private func calculateAngle(for index: Int, selectedIndex: Int, total: Int) -> CGFloat {
        if total == 0 { return 0 }
        
        var offset = Double(index - selectedIndex)
        let half = Double(total) / 2.0
        
        if offset > half {
            offset -= Double(total)
        } else if offset < -half {
            offset += Double(total)
        }
        
        let spacing = min(Double.pi / 8, (Double.pi * 2) / Double(total))
        
        return CGFloat(-Double.pi / 2 + offset * spacing)
    }
}
