//
//  RecordingCard.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

struct CellSpacer: View {
    
    // MARK: - API
    
    var screenHeight: CGFloat
    var numberOfSessions: Int
        
    // MARK: - Variables
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var cellOpacity: Double {
        colorScheme == .dark ? 0.6 : 1.0
    }
    
    private var cellColor: Color {
        colorScheme == .dark ? Color.black.opacity(theme.superGlassy.rawValue) : Color.white.opacity(theme.superGlassy.rawValue)
    }
    
    private var height: Double {
        let height = (screenHeight - (Double(numberOfSessions) * (65.653320 + 1))) + 25
        if height > 150 {
            return height + screenHeight
        } else {
            return 150.0 + screenHeight
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.clear
                .frame(maxWidth: .infinity, minHeight: 150)
                .frame(height: height)
                .ignoresSafeArea()
                .background(
                    cellColor
                )
                .padding(.bottom, -height + 150)
            if numberOfSessions == 0 {
                Text("Create your first recording!")
                    .font(.title)
                    .offset(y: 300)
            }
        }
    }
}

#Preview {
    CellSpacer(screenHeight: 150, numberOfSessions: 0)
}
