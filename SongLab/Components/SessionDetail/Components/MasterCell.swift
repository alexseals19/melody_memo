//
//  MasterCell.swift
//  SongLab
//
//  Created by Alex Seals on 6/12/24.
//

import SwiftUI

struct MasterCell: View {
    var body: some View {
        VStack {
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    HStack() {
                        Text("Master")
                    }
                }
                Spacer()
            }
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    MasterCell()
}
