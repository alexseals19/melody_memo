//
//  AppSettingsView.swift
//  SongLab
//
//  Created by Alex Seals on 6/17/24.
//

import SwiftUI

struct AppSettingsView: View {
    
    @EnvironmentObject private var appTheme: AppTheme

    private let themeImages: [String] = ["basic", "artist"]
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 150, height: 3)
                .foregroundStyle(.primary)
                .padding(15)
                .shadow(color: .white, radius: appTheme.theme.shadowRadius)
            Spacer()
            Text("App Theme")
                .font(.title2)
            HStack {
                ForEach(AppTheme.Theme.allCases) { theme in
                    VStack {
                        Image(theme.rawValue)
                            .resizable()
                            .cornerRadius(15)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 300)
                        Text(theme.rawValue)
                            .font(.caption)
                        if theme == appTheme.theme {
                            ZStack {
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .frame(width: 24)
                                    .aspectRatio(contentMode: .fit)
                                Circle()
                                    .frame(width: 20)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(.primary)
                            }
                        } else {
                            Circle()
                                .stroke(lineWidth: 2)
                                .frame(width: 24)
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .foregroundStyle(.primary)
                    .onTapGesture {
                        appTheme.theme = theme
                    }
                }
            }
            Spacer()
        }
        .presentationDetents([.height(500)])
    }
}

#Preview {
    AppSettingsView()
}
