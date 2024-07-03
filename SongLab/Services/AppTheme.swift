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
            return Color(UIColor.systemBackground).opacity(1.0)
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
                .ignoresSafeArea()
                .opacity(0.5)
                .background(Color(UIColor.systemBackground).opacity(1.0))
        case .artist:
            return Image("swirl")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .opacity(0.3)
                .background(Color.black)
        }
    }
    
    var cellBackground: some View {
        switch theme {
        case .basic:
            return Color.clear
                .background(.ultraThinMaterial.opacity(1.0))
                .background(Color.clear)
                
        case .artist:
            return Color.clear
                .background(.ultraThinMaterial.opacity(0.0))
                .background(Color(UIColor.systemBackground).opacity(0.7))
            
//        case .offWhite:
//            return Color.clear
//                .background(.ultraThinMaterial.opacity(0.6))
//                .background(Color(red: 1.0, green: 1.0, blue: 0.95).opacity(0.7))
        }
        
    }
    
    var toolbarMaterialOpacity: Double {
        switch theme {
        case .basic:
            return 1.0
        case .artist:
            return 0.99
        }
    }
}
