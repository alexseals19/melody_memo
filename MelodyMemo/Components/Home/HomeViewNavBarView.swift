//
//  HomeViewNavBarView.swift
//  SongLab
//
//  Created by Alex Seals on 6/14/24.
//

import SwiftUI

struct HomeViewNavBarView: View {
    
    //MARK: - API
    
    //MARK: - Variables
        
    @EnvironmentObject private var appTheme: AppTheme
    
    //MARK: - Body
    
    var body: some View {
        Color(UIColor.systemBackground).opacity(0.4)
            .background(.ultraThinMaterial)
            .frame(maxWidth: .infinity, maxHeight: 75.0)
            .ignoresSafeArea()
    }
}

#Preview {
    HomeViewNavBarView()
}
