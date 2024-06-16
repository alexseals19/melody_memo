//
//  HomeViewNavBarView.swift
//  SongLab
//
//  Created by Alex Seals on 6/14/24.
//

import SwiftUI

struct HomeViewNavBarView: View {
    
    //MARK: - API
    
    @Binding var appTheme: String
    
    //MARK: - Variables
        
    private var navBarColor: Color {
        appTheme == "light" ? Color.clear : Color.black.opacity(0.5)
    }
    
    //MARK: - Body
    
    var body: some View {
        Rectangle()
            .ignoresSafeArea()
            .foregroundStyle(navBarColor)
            .background(.ultraThinMaterial)
            .frame(maxWidth: .infinity, maxHeight: 15.0)
    }
}

#Preview {
    HomeViewNavBarView(appTheme: .constant("glass"))
}
