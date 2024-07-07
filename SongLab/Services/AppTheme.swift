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
        case blue
        case yellow
        case pink
        case purple
        case green
        case black
        case white
        case cyan
        
        var id: Self { self }
    }
    
    var accentColor: Color {
        switch theme {
        case .red:
            return Color.red
        case .orange:
            return Color.orange
        case .blue:
            return Color.blue
        case .yellow:
            return Color.yellow
        case .pink:
            return Color.pink
        case .purple:
            return Color.purple
        case .green:
            return Color.green
        case .black:
            return Color.black
        case .white:
            return Color.white
        case .cyan:
            return Color.cyan
        }
    }
}
