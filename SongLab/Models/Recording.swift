//
//  Recordings.swift
//  SongLab
//
//  Created by Alex Seals on 6/2/24.
//

import Foundation

struct Recording: Identifiable, Equatable {
    let name: String
    let date: String
    let url: URL
    let id = UUID()
}

