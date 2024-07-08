//
//  ErrorMessageView.swift
//  SongLab
//
//  Created by Alex Seals on 7/8/24.
//

import SwiftUI

struct ErrorMessageView: View {
    
    //MARK: - API
    
    @Binding var message: String?
    
    init(
        message: Binding<String?>
    ) {
        _message = message
    }
    
    private var errorMessage: String {
        if let message {
            return message
        }
        return ""
    }
    
    //MARK: - Variables
    
    @State var opacity: Double = 0.0
    
    //MARK: - Body
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(maxWidth: .infinity, maxHeight: 30)
            .foregroundStyle(.red)
            
            .overlay {
                HStack {
                    Text(errorMessage)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Button {
                        message = nil
                    } label: {
                        Image(systemName: "xmark")
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                }
                .foregroundStyle(.black)
            }
            .padding(.horizontal, 30)
            .opacity(opacity)
            .onAppear {
                withAnimation(.linear(duration: 0.4)) {
                    opacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation(.linear(duration: 0.4)) {
                        self.message = nil
                    }
                    
                }
            }
    }
}

#Preview {
    ErrorMessageView(message: .constant(""))
}
