//
//  TripJournalVM.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import Foundation
internal import Combine

class TripJournalVM: ObservableObject {
    @Published var journal: [TripJournal] = []
    
    init(journal: [TripJournal]) {
        self.journal = journal
    }
    
    func addJournal(_ journal: TripJournal) {
        self.journal.append(journal)
    }
    
    func getJournal() -> [TripJournal] {
        return journal
    }
    
    func addEntries(_ entries: [TripJournal]) {
        self.journal.append(contentsOf: entries)
    }
}
