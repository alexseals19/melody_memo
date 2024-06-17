//
//  TrackingSettingsView.swift
//  SongLab
//
//  Created by Alex Seals on 6/5/24.
//

import SwiftUI

struct TrackingSettingsView: View {
    
    //MARK: - Variables
    
    @State private var isPresented: Bool = false
    
    @EnvironmentObject private var appTheme: AppTheme
    
    //MARK: - Body
    
    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
        .foregroundStyle(.primary)
        .sheet(isPresented: $isPresented) {
            VStack {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 150, height: 3)
                    .foregroundStyle(.primary)
                    .padding(15)
                    .shadow(color: .white, radius: appTheme.theme.shadowRadius)
                Spacer()
                Picker("Theme", selection: $appTheme.theme) {
                    ForEach(AppTheme.Theme.allCases) { theme in
                        Text("\(theme)")
                    }
                }
                Spacer()
            }
            .presentationDetents([.height(200)])
        }
    }
}

#Preview {
    TrackingSettingsView()
}
