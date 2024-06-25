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
        case basic = "basic"
        case basicdark = "basicdark"
        case artist = "artist"
        case light = "light"
        
        var id: Self { self }
    }
    
    var backgroundLayerOpacity: Double {
        switch theme {
        case .basic:
            return 0.4
        case .basicdark:
            return 0.7
        case .artist:
            return 0.0
        case .light:
            return 0.0
        }
    }
    
    var backgroundMaterialOpacity: Double {
        switch theme {
        case .basic:
            return 0.6
        case .basicdark:
            return 0.6
        case .artist:
            return 0.0
        case .light:
            return 0.0
        }
    }
    
    var recordButtonColor: Gradient {
        switch theme {
        case .basic:
            return Gradient(colors: [.red])
        case .basicdark:
            return Gradient(colors: [.red])
        case .artist:
            return Gradient(colors: [.pink, .purple])
        case .light:
            return Gradient(colors: [.red])
        }
    }
    
    var shadowRadius: Double {
        switch theme {
        case .basic:
            return 0.0
        case .basicdark:
            return 0.0
        case .artist:
            return 10.0
        case .light:
            return 0.0
        }
    }
    
    var playbackControlColor: Gradient {
        switch theme {
        case .basic:
            return Gradient(colors: [.primary])
        case .basicdark:
            return Gradient(colors: [.primary])
        case .artist:
            return Gradient(colors: [.pink, .purple])
        case .light:
            return Gradient(colors: [.primary])
        }
    }
    
    var cellColor: Color {
        switch theme {
        case .basic:
            return Color(UIColor.systemBackground).opacity(0.9)
        case .basicdark:
            return Color.black.opacity(0.8)
        case .artist:
            return Color.black.opacity(0.7)
        case .light:
            return Color.white.opacity(0.5)
        }
    }
    
    var navBarColor: Color {
        switch theme {
        case .basic:
            return Color(UIColor.secondarySystemBackground).opacity(0.5)
        case .basicdark:
            return Color.black.opacity(0.5)
        case .artist:
            return Color.black.opacity(0.5)
        case .light:
            return Color.clear
        }
    }
    
    var backgroundImage: Image {
        switch theme {
        case .basic:
            return Image("swirl")
        case .basicdark:
            return Image("swirl")
        case .artist:
            return Image("swirl")
        case .light:
            return Image("swirl")
        }
    }
    
    var backgroundShade: Color {
        switch theme {
        case .basic:
            return Color(UIColor.secondarySystemBackground)
        case .basicdark:
            return Color.black
        case .artist:
            return Color.black
        case .light:
            return Color.clear
        }
    }
    
    var backgroundImageOpacity: Double {
        switch theme {
        case .basic:
            return 0.3
        case .basicdark:
            return 0.75
        case .artist:
            return 0.3
        case .light:
            return 0.3
        }
    }
}
