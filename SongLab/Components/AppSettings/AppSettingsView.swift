//
//  AppSettingsView.swift
//  SongLab
//
//  Created by Alex Seals on 6/17/24.
//

import SwiftUI

struct AppSettingsView: View {
    
    //MARK: - API
    
    @Binding var metronomeBpm: Double
    @Binding var isCountInActive: Bool
        
    init(metronome: Metronome, metronomeBpm: Binding<Double>, isCountInActive: Binding<Bool>) {
        _viewModel = StateObject(
            wrappedValue: AppSettingsViewModel(metronome: metronome)
        )
        _metronomeBpm = metronomeBpm
        _isCountInActive = isCountInActive
    }
    
    //MARK: - Variables
    
    @EnvironmentObject private var appTheme: AppTheme
    
    @StateObject private var viewModel: AppSettingsViewModel
    
    @State var isOn: Bool = false
        
    //MARK: - Body
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 150, height: 3)
                .foregroundStyle(.primary)
                .padding(15)
                .shadow(color: .white, radius: appTheme.shadowRadius)
            ScrollView {
                LazyVStack {
                    
                    Text("Metronome Settings")
                        .font(.title2)
                        .padding(.top, 25)
                    HStack {
                        Text("BPM \(Int(metronomeBpm))")
                        Button {
                            isCountInActive.toggle()
                        } label: {
                            if isCountInActive {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                        .frame(width: 75, height: 25)
                                        .foregroundStyle(.pink)
                                    Text("Count In")
                                        .font(.caption)
                                        .foregroundStyle(.black)
                                }
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(lineWidth: 1.0)
                                        .frame(width: 75, height: 25)
                                        .foregroundStyle(.pink)
                                    Text("Count In")
                                        .font(.caption)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                    Slider(value: $metronomeBpm, in: 1 ... 300)
                        .tint(.primary)
                        .padding(.horizontal, 20)
                    Divider()
                    Text("App Theme")
                        .font(.title2)
                        .padding(.top, 25)
                    LazyHStack {
                        ForEach(AppTheme.Theme.allCases) { theme in
                            VStack {
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
}

#Preview {
    AppSettingsView(metronome: Metronome.shared, metronomeBpm: .constant(120), isCountInActive: .constant(false))
}
