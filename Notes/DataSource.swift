//
//  Data.swift
//  Notes
//
//  Created by Denis Zayakin on 5/15/19.
//  Copyright © 2019 Denis Zayakin. All rights reserved.
//

import Foundation

struct Note {
    let id: String
    let date: Date
    let detail: String
    
    var shortDetail: String {
        if detail.count > 100 {
            let index = detail.index(detail.startIndex, offsetBy: 100)
            return String(detail[..<index]) + "..."
        } else {
            return detail
        }
    }
//    init?() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "d MMM yyyy HH:mm:ss"
//        dateForSort = dateFormatter.string(from: Date())
//        dateFormatter.dateFormat = "dd.MM"
//        date = dateFormatter.string(from: Date())
//        dateFormatter.dateFormat = "HH:mm"
//        time = dateFormatter.string(from: Date())
//        detail = ""
//        id = DataSource.shared.globalId
//    }
}

class DataSource {
    
    static var shared = DataSource()
    
    private(set) var noteList: [Note] = []
    private(set) var filteredNoteList: [Note] = []
    
    var sortedNotes: [Note] = []
    var isSearching: Bool = false
    var globalId: Int = 0
    
    var selectedNoteDetail: String?
    var noteIndex: Int?
    var toReloadTableview: Bool?

    func append(note: Note) {
        globalId += 1
        self.noteList.append(note)
    }
    
    func removeInNoteList(at index: Int) {
        self.noteList.remove(at: index)
    }
    
    func removeInfilteredNoteList(at index: Int) {
        self.filteredNoteList.remove(at: index)
    }

    func editInNoteList(at index: Int, editedNote: Note) {
        self.noteList[index] = editedNote
    }
    
    func editInfilteredNoteList(at index: Int, editedNote: Note) {
        self.filteredNoteList[index] = editedNote
    }
    
    func copyListToFilteredList() {
        DataSource.shared.filteredNoteList = NSMutableArray(array: DataSource.shared.noteList) as! [Note]
    }
    
    func cleanFilteredList() {
        DataSource.shared.filteredNoteList.removeAll()
    }
    
    func filterNoteList(searchText: String) {
        DataSource.shared.filteredNoteList = DataSource.shared.noteList.filter({( note : Note) -> Bool in
            return note.detail.lowercased().contains(searchText.lowercased())
        })
    }
    
    func sort(_ type: Sort) {
        switch type {
        case .byName:
            noteList.sort { return $0.detail < $1.detail }
        case .fromNewToOld:
            noteList.sort { return $0.date > $1.date }
        case .fromOldToNew:
            noteList.sort { return $0.date < $1.date }
        }
    }
 
}