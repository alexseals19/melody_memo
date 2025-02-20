//
//  CellSpacerView.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

struct CellSpacerView: View {
    
    // MARK: - API
    
    var screenHeight: CGFloat
    var numberOfSessions: Int
    var showMessage: Bool
    var isUpdatingSessionModels: Bool?
        
    // MARK: - Variables
    
    @EnvironmentObject private var appTheme: AppTheme
    
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
            Color(.clear)
                .frame(maxWidth: .infinity, minHeight: 150)
                .frame(height: height)
                .ignoresSafeArea()
                .padding(.bottom, -height + 150)
            if isUpdatingSessionModels != nil {
                Text("Currently updating sessions...")
                    .font(.title)
                    .offset(y: 300)
            } else if numberOfSessions == 0, showMessage {
                Text("Create your first recording!")
                    .font(.title)
                    .offset(y: 300)
            }
        }
    }
}

#Preview {
    CellSpacerView(screenHeight: 150, numberOfSessions: 0, showMessage: true)
}
