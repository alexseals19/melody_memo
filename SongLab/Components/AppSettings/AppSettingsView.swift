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
                .foregroundStyle(appTheme.accentColor)
                .padding(15)
                .shadow(color: appTheme.accentColor, radius: 5)
            ScrollView {
                LazyVStack {
                    
                    Text("Metronome")
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
                                        .foregroundStyle(appTheme.accentColor)
                                    Text("Count In")
                                        .font(.caption)
                                        .foregroundStyle(.black)
                                }
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(lineWidth: 1.0)
                                        .frame(width: 75, height: 25)
                                        .foregroundStyle(appTheme.accentColor)
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
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60, maximum: 60))]) {
                        ForEach(AppTheme.Theme.allCases) { theme in
                            Group {
                                if theme == appTheme.theme {
                                    ZStack {
                                        Circle()
                                            .stroke(lineWidth: 2)
                                            .foregroundStyle(Color[theme.rawValue])
                                            .frame(width: 40)
                                            .aspectRatio(contentMode: .fit)
                                        Circle()
                                            .frame(width: 36)
                                            .foregroundStyle(Color[theme.rawValue])
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundStyle(.primary)
                                    }
                                } else {
                                    Circle()
                                        .stroke(lineWidth: 2)
                                        .foregroundStyle(Color[theme.rawValue])
                                        .frame(width: 40)
                                        .aspectRatio(contentMode: .fit)
                                }
                            }
                            .padding(.bottom, 10)
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

extension Color {
    static subscript(name: String) -> Color {
        switch name {
        case "red":
            return Color.red
        case "orange":
            return Color.orange
        case "blue":
            return Color.blue
        case "yellow":
            return Color.yellow
        case "pink":
            return Color.pink
        case "purple":
            return Color.purple
        case "black":
            return Color.black
        case "white":
            return Color.white
        case "green":
            return Color.green
        case "cyan":
            return Color.cyan
        default:
            return Color.red
        }
    }
}

#Preview {
    AppSettingsView(metronome: Metronome.shared, metronomeBpm: .constant(120), isCountInActive: .constant(false))
}
