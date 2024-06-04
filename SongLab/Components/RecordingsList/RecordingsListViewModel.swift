//
//  RecordingsListViewModel.swift
//  SongLab
//
//  Created by Alex Seals on 6/4/24.
//

import Foundation

@MainActor
class RecordingsListViewModel: ObservableObject {
    
    //MARK: - API
    
    @Published var currentlyPlaying: Recording?
    
    public var recordings: [Recording] = []
    
    init(recordings: [Recording]) {
        self.recordings = recordings
    }
    
    public func doSomethingPublic() {}
    
    // MARK: - Variables
    
    // MARK: - Functions
    
    private func doSomethingPrivate() {}
}
