//
//  HomeViewNavBarView.swift
//  SongLab
//
//  Created by Alex Seals on 6/14/24.
//

import SwiftUI

struct HomeViewNavBarView: View {
    
    //MARK: - API
    
    @Binding var isSettingsPresented: Bool
    
    init(
        isSettingsPresented: Binding<Bool>,
        isRecording: Bool
    ) {
        _isSettingsPresented = isSettingsPresented
        self.isRecording = isRecording
    }
    
    //MARK: - Variables
        
    @EnvironmentObject private var appTheme: AppTheme
    
    private var isRecording: Bool
    
    //MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            Color(UIColor.systemBackground).opacity(0.4)
                .background(.ultraThinMaterial)
                .frame(maxWidth: .infinity, maxHeight: 75.0)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HomeViewNavBarView(
        isSettingsPresented: .constant(false),
        isRecording: false
    )
}
