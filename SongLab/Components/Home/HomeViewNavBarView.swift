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
        Rectangle()
            .ignoresSafeArea()
            .foregroundStyle(appTheme.navBarColor)
            .background(.ultraThinMaterial)
            .frame(maxWidth: .infinity, maxHeight: 15.0)
    }
}

#Preview {
    HomeViewNavBarView()
}
