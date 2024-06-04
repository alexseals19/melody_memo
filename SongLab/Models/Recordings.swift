//
//  Recordings.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import SwiftUI

class Recordings: ObservableObject {
    @Published var recordings: [String]
    
    init (recordings: [String]) {
        self.recordings = recordings
    }
}
