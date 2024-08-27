//
//  AppTheme.swift
//  SongLab
//
//  Created by Alex Seals on 6/17/24.
//

import Foundation
import SwiftUI

class AppTheme: ObservableObject {

    @AppStorage("appTheme") var theme: Theme = .red
    
    enum Theme: String, CaseIterable, Identifiable {
        case red
        case orange
        case yellow
        case green
        case cyan
        case blue
        case purple
        case pink
        case black
        case white
        
        
        var id: Self { self }
    }
    
    var accentColor: Color {
        switch theme {
        case .red:
            return Color.red
        case .orange:
            return Color.orange
        case .yellow:
            return Color.yellow
        case .green:
            return Color.green
        case .cyan:
            return Color.cyan
        case .blue:
            return Color.blue
        case .purple:
            return Color.purple
        case .pink:
            return Color.pink
        case .black:
            return Color.black
        case .white:
            return Color.white
        
        }
    }
}
