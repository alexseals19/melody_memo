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
    @Binding var metronomeVolume: Float
    @Binding var isCountInActive: Bool
        
    init(metronome: Metronome,
         audioManager: AudioManager,
         metronomeBpm: Binding<Double>,
         metronomeVolume: Binding<Float>,
         isCountInActive: Binding<Bool>
    ) {
        _viewModel = StateObject(
            wrappedValue: AppSettingsViewModel(metronome: metronome, audioManager: audioManager)
        )
        _metronomeBpm = metronomeBpm
        _metronomeVolume = metronomeVolume
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
                        .padding(.top, 15)
                    HStack {
                        
                        Button {
                            if metronomeBpm > 1 {
                                metronomeBpm -= 1
                            }
                        } label: {
                            bpmAdjustmentLabelView(name: "minus")
                                .foregroundStyle(.primary)
                        }
                        .buttonRepeatBehavior(.enabled)
                        VStack {
                            Text("BPM")
                                .font(.caption)
                            Text("\(Int(metronomeBpm))")
                        }
                        .foregroundStyle(.secondary)
                        Button {
                            if metronomeBpm < 300 {
                                metronomeBpm += 1
                            }
                        } label: {
                            bpmAdjustmentLabelView(name: "plus")
                                .foregroundStyle(.primary)
                        }
                        .buttonRepeatBehavior(.enabled)
                        .padding(.trailing, 10)
                        Button {
                            isCountInActive.toggle()
                        } label: {
                            countInButtonLabel
                        }
                    }
                    .foregroundStyle(.primary)
                    HStack {
                        bpmAdjustmentLabelView(name: "speaker.wave.2")
                            .foregroundStyle(.secondary)
                        Slider(value: $metronomeVolume)
                            .tint(.primary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    
                    Divider()
                    
                    Text("Tracking")
                        .font(.title2)
                        .padding(.top, 15)
                    HStack {
                        Text("Minimum recording length")
                            .padding(.trailing, 15)
                        Button {
                            if viewModel.trackLengthLimit > 0 {
                                viewModel.trackLengthLimit -= 1
                            }
                        } label: {
                            bpmAdjustmentLabelView(name: "minus")
                        }
                        .foregroundStyle(.primary)
                        VStack {
                            if viewModel.trackLengthLimit > 0 {
                                Text("\(viewModel.trackLengthLimit)")
                                Text("sec")
                                    .font(.caption)
                            } else {
                                Text("off")
                                    .font(.body)
                            }
                        }
                        .foregroundStyle(.secondary)
                        Button {
                            if viewModel.trackLengthLimit < 5 {
                                viewModel.trackLengthLimit += 1
                            }
                        } label: {
                            bpmAdjustmentLabelView(name: "plus")
                        }
                        .foregroundStyle(.primary)
                        .padding(.trailing, 10)
                    }
                    Text("Only keep new recordings longer than this.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 10)
                    
                    Divider()
                    
                    Text("App Theme")
                        .font(.title2)
                        .padding(.top, 15)
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
                                changeIcon(to: "Icon_\(theme.rawValue)")
                                appTheme.theme = theme
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                }
                .presentationDetents([.height(375)])
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 360)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                viewModel.saveSettings()
        }
        
    }
    
    var countInButtonLabel: some View {
        ZStack {
            if isCountInActive {
                RoundedRectangle(cornerRadius: 25)
                    .frame(width: 75, height: 25)
                    .foregroundStyle(appTheme.accentColor)
                Text("Count In")
                    .font(.caption)
                    .foregroundStyle(.black)
            } else {
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
    
    private func changeIcon(to name: String?) {
        if UIApplication.shared.responds(
            to: #selector(
                getter: UIApplication.supportsAlternateIcons)) && UIApplication.shared.supportsAlternateIcons {
            
            typealias setAlternateIconNameClosure = @convention(c) (NSObject, Selector, NSString?, @escaping (NSError) -> ()) -> ()
            
            let selectorString = "_setAlternateIconName:completionHandler:"
            
            let selector = NSSelectorFromString(selectorString)
            let imp = UIApplication.shared.method(for: selector)
            let method = unsafeBitCast(imp, to: setAlternateIconNameClosure.self)
            method(UIApplication.shared, selector, name as NSString?, { _ in })
        }
    }
}

struct bpmAdjustmentLabelView: View {
    
    var name: String
    
    var body: some View {
        Image(systemName: name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
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
    AppSettingsView(
        metronome: Metronome.shared,
        audioManager: MockAudioManager(),
        metronomeBpm: .constant(120),
        metronomeVolume: .constant(1.0),
        isCountInActive: .constant(false)
    )
}
