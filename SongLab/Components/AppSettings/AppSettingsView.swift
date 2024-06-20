//
//  AppSettingsView.swift
//  SongLab
//
//  Created by Alex Seals on 6/17/24.
//

import SwiftUI

struct AppSettingsView: View {
    
    //MARK: - API
    
    @AppStorage("bpm") var bpm: Int = 120
        
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
                Text("BPM \(bpm)")
                Slider(value: $sliderValue, in: 1 ... 300)
                    .tint(.primary)
                    .padding(.horizontal, 20)
                    .onChange(of: sliderValue) {
                        bpm = Int(sliderValue)
                    }
                Text("App Theme")
                    .font(.title2)
                ScrollView(.horizontal) {
                    LazyHStack {
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
