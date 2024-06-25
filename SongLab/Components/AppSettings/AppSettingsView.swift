//
//  AppSettingsView.swift
//  SongLab
//
//  Created by Alex Seals on 6/17/24.
//

import SwiftUI

struct AppSettingsView: View {
    
    //MARK: - API
    
    @AppStorage("bpm") var bpm: Double = 120
        
    init(metronome: Metronome) {
        _viewModel = StateObject(
            wrappedValue: AppSettingsViewModel(metronome: metronome)
        )
        sliderValue = Double(metronome.bpm)
    }
    
    //MARK: - Variables
    
    @EnvironmentObject private var appTheme: AppTheme
    
    @StateObject private var viewModel: AppSettingsViewModel
    
    @State private var sliderValue: Double
    
    //MARK: - Body
    
    var body: some View {
        ScrollView {
            LazyVStack {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 150, height: 3)
                    .foregroundStyle(.primary)
                    .padding(15)
                    .shadow(color: .white, radius: appTheme.shadowRadius)
                Spacer()
                Text("BPM \(Int(bpm))")
                Slider(value: $bpm, in: 1 ... 300)
                    .tint(.primary)
                    .padding(.horizontal, 20)
                Text("App Theme")
                    .font(.title2)
                LazyHStack {
                    ForEach(AppTheme.Theme.allCases) { theme in
                        VStack {
                            Image(theme.rawValue)
                                .resizable()
                                .cornerRadius(15)
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 300)
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
                .padding(.horizontal, 20)
                Spacer()
            }
            .presentationDetents([.height(500)])
        }
    }
}

#Preview {
    AppSettingsView(metronome: Metronome())
}
