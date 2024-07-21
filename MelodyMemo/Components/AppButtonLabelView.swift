//
//  AppButtonLabelView.swift
//  MelodyMemo
//
//  Created by Alex Seals on 7/20/24.
//

import SwiftUI

struct AppButtonLabelView: View {
    
    //MARK: - API
    
    let name: String
    let color: Color
    var size: CGFloat
    
    init(
        name: String,
        color: Color,
        size: CGFloat = 24
    ) {
        self.name = name
        self.color = color
        self.size = size
    }
    
    //MARK: - Body
    
    var body: some View {
        Image(systemName: name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundStyle(color)
    }
}

#Preview {
    AppButtonLabelView(name: "Button", color: .primary)
}
