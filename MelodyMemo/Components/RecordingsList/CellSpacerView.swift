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
    
    init(screenHeight: CGFloat,
         numberOfSessions: Int,
         showMessage: Bool,
         isUpdatingSessionModels: Bool? = nil,
         cellType: CellType
    ) {
        self.screenHeight = screenHeight
        self.numberOfSessions = numberOfSessions
        self.showMessage = showMessage
        self.isUpdatingSessionModels = isUpdatingSessionModels
        self.cellType = cellType
    }
        
    // MARK: - Variables
    
    @EnvironmentObject private var appTheme: AppTheme
    
    private let cellType: CellType
    
    private var cellColor: Color {
        if cellType == .session {
            return Color(UIColor.secondarySystemBackground).opacity(0.5)
        } else {
            return Color(UIColor.secondarySystemBackground).opacity(0.0)
        }
    }
    
    private var cellTypeHeight: Double {
        return cellType == .session ? 65.653320 : 150
    }
    
    private var height: Double {
        let height = (screenHeight - (Double(numberOfSessions) * (cellTypeHeight + 1))) + 25
        if height > 150 {
            return height + screenHeight
        } else {
            return 150.0 + screenHeight
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .foregroundStyle(cellColor)
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
    CellSpacerView(screenHeight: 150, numberOfSessions: 0, showMessage: true, cellType: CellType.track)
}
