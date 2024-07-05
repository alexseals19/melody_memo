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
        case artist = "artist"
        
        var id: Self { self }
    }
    
    var recordButtonColor: Gradient {
        switch theme {
        case .basic:
            return Gradient(colors: [.red])
        case .artist:
            return Gradient(colors: [.pink, .purple])
        }
    }
    
    var shadowRadius: Double {
        switch theme {
        case .basic:
            return 0.0
        case .artist:
            return 10.0
        }
    }
    
    var playbackControlColor: Gradient {
        switch theme {
        case .basic:
            return Gradient(colors: [.primary])
        case .artist:
            return Gradient(colors: [.pink, .purple])
        }
    }
    
    var cellColor: Color {
        switch theme {
        case .basic:
            return Color.clear
        case .artist:
            return Color(UIColor.systemBackground).opacity(0.7)
        }
    }
    
    var cellMaterialOpacity: Double {
        switch theme {
        case .basic:
            return 1.0
        case .artist:
            return 0.0
        }
    }
    
    var cellDividerColor: Color {
        switch theme {
        case .basic:
            return Color(UIColor.secondaryLabel).opacity(0.4)
        case .artist:
            return Color.clear
        }
    }
    
    var navBarColor: Color {
        switch theme {
        case .basic:
            return Color.clear
        case .artist:
            return Color(UIColor.systemBackground).opacity(0.5)
        }
    }
    
    var backgroundImage: some View {
        switch theme {
        case .basic:
            return Image("swirl")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .blur(radius: 15)
                .ignoresSafeArea()
                .opacity(0.7)
                .background(Color.clear.opacity(1.0))
        case .artist:
            return Image("swirl")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .blur(radius: 0.0)
                .ignoresSafeArea()
                .opacity(0.3)
                .background(Color.black)
        }
    }
    
    var cellBackground: some View {
        switch theme {
        case .basic:
            return Color.clear
                .background(Color(UIColor.systemBackground).opacity(0.3))
                .background(Color.black.opacity(0.0))
                
        case .artist:
            return Color.clear
                .background(Color.white.opacity(0.0))
                .background(Color(UIColor.systemBackground).opacity(0.7))
        }
        
    }
    
    var toolbarMaterialOpacity: Double {
        switch theme {
        case .basic:
            return 0.95
        case .artist:
            return 0.95
        }
    }
}
