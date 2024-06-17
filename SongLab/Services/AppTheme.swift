//
//  AppTheme.swift
//  SongLab
//
//  Created by Alex Seals on 6/17/24.
//

import Foundation
import SwiftUI

class AppTheme: ObservableObject {
        
    @AppStorage("appTheme") var theme: Theme = .basic
    
    enum Theme: String, CaseIterable, Identifiable {
        case basic = "Basic"
        case artist = "Artist"
        
        var id: Self { self }
        
        var backgroundLayerOpacity: Double {
            switch self {
            case .basic:
                return 0.7
            case .artist:
                return 0.0
            }
        }
        
        var backgroundMaterialOpacity: Double {
            switch self {
            case .basic:
                return 0.6
            case .artist:
                return 0.0
            }
        }
        
        var recordButtonColor: Gradient {
            switch self {
            case .basic:
                return Gradient(colors: [.red])
            case .artist:
                return Gradient(colors: [.pink, .purple])
            }
        }
        
        var shadowRadius: Double {
            switch self {
            case .basic:
                return 0.0
            case .artist:
                return 10.0
            }
        }
        
        var playbackControlColor: Gradient {
            switch self {
            case .basic:
                return Gradient(colors: [.primary])
            case .artist:
                return Gradient(colors: [.pink, .purple])
            }
        }
        
        var cellColor: Color {
            switch self {
            case .basic:
                return Color.black.opacity(0.8)
            case .artist:
                return Color.black.opacity(0.5)
            }
        }
        
        var navBarColor: Color {
            switch self {
            case .basic:
                return Color.black.opacity(0.5)
            case .artist:
                return Color.black.opacity(0.5)
            }
        }
        
        var backgroundImage: Image {
            switch self {
            case .basic:
                return Image("calathea_wallpaperpsd")
            case .artist:
                return Image("swirl")
            }
        }
        
        var backgroundImageOpacity: Double {
            switch self {
            case .basic:
                return 0.75
            case .artist:
                return 0.3
            }
        }
        
    }
}
