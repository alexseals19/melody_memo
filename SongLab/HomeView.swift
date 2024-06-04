//
//  ContentView.swift
//  SongLab
//
//  Created by Alex Seals on 2/3/24.
//

import SwiftUI

struct HomeView: View {
    
    
    
    var body: some View {
        VStack {
            RecordingsView()
            Divider()
            Divider()
            
            
            RecordButtonView()
                .ignoresSafeArea()
                .padding(.top)
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
